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
                :supports

    def initialize(desc)
      @name      = desc[:name]
      @version   = desc[:version]
      @root      = desc[:root]
      @includes  = desc[:includes]
      @libraries = desc[:libraries]
      @binaries  = desc[:binaries]
      @sdks      = desc[:sdks]
      @supports  = desc[:supports]
    end

    def self.find(product, version)
      if VisualStudio::Product::NAMES.include?(product)
        name = Helpers::PrettyString.new VisualStudio::VERSION_TO_NAME[version],
                                         pretty: VisualStudio::VERSION_TO_PRETTY_NAME[version]

        root = self._find_via_registry(product, version)
        return nil if root.nil?

        includes, libraries, binaries =
          case product
            when 'VC'
              case version.to_f
                when 8.0..11.0
                  # TODO(mtwilliams): Check if x86_64 support exists.
                  includes  = [File.join(root, 'VC', 'include')]
                  libraries = {:x86    => [File.join(root, 'VC', 'lib')],
                               :x86_64 => []}
                  binaries  = {:x86    => [File.join(root, 'VC', 'bin')],
                               :x86_64 => []}
                  [includes, libraries, binaries]
                when 12.0..14.0
                  # TODO(mtwilliams): Select the 64-bit and ARM host variants
                  # when applicable, i.e. when running on 64-bit or ARM.
                  includes  = [File.join(root, 'VC', 'include')]
                  libraries = {:x86    => [File.join(root, 'VC', 'lib')],
                               :x86_64 => [File.join(root, 'VC', 'lib', 'amd64')],
                               :arm    => [File.join(root, 'VC', 'lib', 'arm')]}
                  binaries  = {:x86    => [File.join(root, 'VC', 'bin')],
                               :x86_64 => [File.join(root, 'VC', 'bin', 'x86_amd64')],
                               :arm    => [File.join(root, 'VC', 'bin', 'x86_arm')]}
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
        # TODO(mtwilliams): Actually search for the SDKs.
        sdks = VisualStudio::VERSION_TO_SDKS[version][:windows]

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
                                              architectures: architectures}))
      else
        # TODO(mtwilliams): Raise an exception.
        # raise VisualStudio::InvalidVersion.new(...)
      end
    end

    private
      def self._find_via_registry(product, version)
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
      end
  end
end
