module VisualStudio
  class Product
    NAMES               = ['VC', 'VC#']
    PRETTY_NAMES        = ['Visual C/C++', 'Visual C#']
    NAME_TO_PRETTY_NAME = Hash[NAMES.zip(PRETTY_NAMES)]

    attr_reader :name,
                :version,
                :root,
                :includes,
                :libraries,
                :binaries,
                :sdks,
                :supports,
                :shared

    def initialize(desc)
      @name      = desc[:name]
      @version   = desc[:version]
      @root      = desc[:root]
      @includes  = desc[:includes]
      @libraries = desc[:libraries]
      @binaries  = desc[:binaries]
      @sdks      = desc[:sdks]
      @supports  = desc[:supports]
      @shared    = desc[:shared]
    end

    def environment(opts={})
      # TODO(mtwilliams): Raise an exception.
      return nil unless @name.to_s == 'VC'

      target = opts[:target] || {platform: :windows,
                                 architecture: :x86}

      # TODO(mtwilliams): Handle other platforms.
      # TODO(mtwilliams): Check if the architecture is supported.
      platform = :windows
      arch = {:x86 => 'x86', :x86_64 => 'amd64', :arm => 'arm'}[target[:architecture]]

      # TODO(mtwilliams): Raise an exception.
      return nil unless arch

      if @shared
        # HACK(mtwilliams): Microsoft shipped a broken `vcvarsall.bat`, so
        # we need to build the envrionment ourself.

        root = File.expand_path(File.join(@root, ".."))

        # TODO(mtwilliams): Insert missing variables into environment.
         # WindowsSdkDir
         # WindowsLibPath
         # WindowsSDKVersion
         # UCRTVersion
         # UniversalCRTSdkDir
         # DevEnvDir
         # INCLUDE
         # LIB
         # LIBPATH

        path = []

        # TODO(mtwilliams): Inject latest Windows SDK into PATH.
        case arch
          when 'x86'
            path << File.join(root, "bin")
          else
            path << File.join(root, "bin", arch)
          end

        env = {
          "VS140COMNTOOLS" => File.join(root, "Common7", "Tools"),
          "VSINSTALLDIR"   => root,
          "VCINSTALLDIR"   => File.join(root, "VC"),
          "PATH"           => path.join(';')
        }

        env = VisualStudio::Environment.merge(opts[:base] || {}, env)
        env = VisualStudio::Environment.merge(env, opts[:overlay] || {})

        env
      else
        # HACK(mtwilliams): We should reimplement this logic inside this gem.
        require 'open3'
        require 'json'

        cmd   = "call \"#{File.join(@root, 'vcvarsall.bat')}\" #{arch} & " +
                "echo require('json'); print JSON.generate(ENV.to_h); | ruby\n"
        out, _, status = Open3.capture3(ENV.to_h, "cmd.exe /C \"#{cmd}\"")
        return nil unless status == 0

        env = VisualStudio::Environment.merge(opts[:base] || {}, JSON.parse(out))
        env = VisualStudio::Environment.merge(env, opts[:overlay] || {})

        env
      end
    end

    def self.find(product, version)
      if VisualStudio::Product::NAMES.include?(product)
        name = Helpers::PrettyString.new product,
                                         pretty: VisualStudio::VERSION_TO_PRETTY_NAME[version]

        root = self._find_via_registry(product, version)
        return nil if root.nil?

        # If shared, indicates everything is fucked up and Microsoft can't be
        # trusted. As such, we need to unfuck things downstream.
        shared = root.downcase.include? 'shared'

        includes, libraries, binaries =
          case product
            when 'VC'
              case version.to_f
                when 8.0..11.0
                  # TODO(mtwilliams): Check if x86_64 support exists.
                  includes  = [File.join(root, 'include')]
                  libraries = {:x86    => [File.join(root, 'lib')],
                               :x86_64 => []}
                  binaries  = {:x86    => [File.join(root, 'bin')],
                               :x86_64 => []}
                  [includes, libraries, binaries]
                when 12.0..14.0
                  # TODO(mtwilliams): Select the 64-bit and ARM host variants
                  # when applicable, i.e. when running on 64-bit or ARM.
                  includes  = [File.join(root, 'include')]
                  libraries = {:x86    => [File.join(root, 'lib')],
                               :x86_64 => [File.join(root, 'lib', 'amd64')],
                               :arm    => [File.join(root, 'lib', 'arm')]}
                  binaries  = {:x86    => [File.join(root, 'bin')],
                               :x86_64 => [File.join(root, 'bin', 'x86_amd64')],
                               :arm    => [File.join(root, 'bin', 'x86_arm')]}
                  [includes, libraries, binaries]
                else
                  # TODO(mtwilliams): Raise a proper extension.
                  # raise VisualStudio::Unsupported(...)
                  raise "Wha-?"
                end
            when 'VC#'
              # TODO(mtwilliams): Determine search paths.
              [[], {}, {}]
            end

        # TODO(mtwilliams): Handle the Xbox One and PS4.
        sdks = (VisualStudio::VERSION_TO_SDKS[version][:windows].map do |version|
                  Windows::SoftwareDevelopmentKit.find(version)
                end).compact

        platforms = [:windows]
        architectures = case product
                          when 'VC'
                            case version.to_f
                              when 8.0..11.0
                                # TODO(mtwilliams): Check if x86_64 support exists.
                                [:x86]
                              when 12.0..14.0
                                [:x86, :x86_64, :arm]
                              end
                          when 'VC#'
                            # TODO(mtwilliams): Determine 64-bit support?
                            [:x86, :x86_64, :arm]
                          end

        VisualStudio::Product.new(name: name,
                                  version: version,
                                  root: root,
                                  includes: includes,
                                  libraries: libraries,
                                  binaries: binaries,
                                  sdks: ({windows: sdks}),
                                  supports: ({platforms: platforms,
                                              architectures: architectures}),
                                  shared: shared)
      else
        # TODO(mtwilliams): Raise an exception.
        # raise VisualStudio::InvalidVersion.new(...)
      end
    end

    private
      def self._find_via_registry(product, version)
        case version.to_f
          when 8.0..14.0
            # We try to find a full version of Visual Studio. If we can't, then
            # we look for standalone verions, i.e. Express Editions. This is only
            # required for 2005-2010 so this logic can be removed when we drop
            # support for them.
            keys = ["SOFTWARE\\Wow6432Node\\Microsoft\\VisualStudio\\#{version}\\Setup\\#{product}",
                    "SOFTWARE\\Microsoft\\VisualStudio\\#{version}\\Setup\\#{product}",
                    "SOFTWARE\\Wow6432Node\\Microsoft\\VCExpress\\#{version}\\Setup\\#{product}",
                    "SOFTWARE\\Microsoft\\VCExpress\\#{version}\\Setup\\#{product}"]
            installs = keys.map do |key|
              begin
                require 'win32/registry'
                return File.expand_path(::Win32::Registry::HKEY_LOCAL_MACHINE.open(key, ::Win32::Registry::KEY_READ)['ProductDir']).to_s
              rescue
              end
            end
            installs.compact.first
          when 15.0
            raise "Not supported yet!"
          end        
      end
  end
end
