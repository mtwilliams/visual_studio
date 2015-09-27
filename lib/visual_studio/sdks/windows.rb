module VisualStudio
  module Windows
    class SoftwareDevelopmentKit
      VERSIONS = [10.0, 8.1, 8.0, 7.1, 7.0].map(&:to_s)

      attr_reader :name,
                  :version,
                  :root,
                  :includes,
                  :libraries,
                  :binaries,
                  :supports

      def initialize(desc)
        @name      = desc[:name]
        @version   = desc[:version]
        @root      = desc[:root]
        @includes  = desc[:includes]
        @libraries = desc[:libraries]
        @binaries  = desc[:binaries]
        @supports  = desc[:supports]
      end

      def self.find(version)
        if Windows::SoftwareDevelopmentKit::VERSIONS.include?(version)
          # TODO(mtwilliams): Select the 64-bit and ARM host variants when
          # applicable, i.e. when running on 64-bit or ARM.

          name, version, root, includes, libraries, binaries, supports =
            case version.to_f
              when 7.0..7.1
                name, root = self._find_via_registry(version)
                return nil if root.nil?

                includes  = [File.join(root, 'include')]

                libraries = {:x86    => [File.join(root, 'lib')],
                             :x86_64 => [File.join(root, 'lib', 'x64')].select{|path| Dir.exists?(path)}}
                binaries  = {:x86    => [File.join(root, 'bin')],
                             :x86_64 => [File.join(root, 'bin', 'x64')].select{|path| Dir.exists?(path)}}

                supports = []
                 supports << :x86
                 supports << :x86_64 if !libraries[:x86_64].empty?

                [name, version, root, includes, libraries, binaries, supports]
              when 8.0
                name, root = self._find_kit_via_registry(version)
                return nil if root.nil?

                includes  = [File.join(root, 'include', 'shared'),
                             File.join(root, 'include', 'um')]
                libraries = {:x86    => [File.join(root, 'lib', 'win8', 'um', 'x86')],
                             :x86_64 => [File.join(root, 'lib', 'win8', 'um', 'x64')]}
                binaries  = {:x86    => [File.join(root, 'bin', 'x86')],
                             :x86_64 => [File.join(root, 'bin', 'x64')]}

                supports = [:x86, :x86_64]

                [name, version, root, includes, libraries, binaries, supports]
              when 8.1
                name, root = self._find_kit_via_registry(version)
                return nil if root.nil?

                includes  = [File.join(root, 'include', 'shared'),
                             File.join(root, 'include', 'um')]
                libraries = {:x86    => [File.join(root, 'lib', 'winv6.3', 'um', 'x86')],
                             :x86_64 => [File.join(root, 'lib', 'winv6.3', 'um', 'x64')],
                                :arm => [File.join(root, 'lib', 'winv6.3', 'um', 'arm')]}
                binaries  = {:x86    => [File.join(root, 'bin', 'x86')],
                             :x86_64 => [File.join(root, 'bin', 'x64')],
                                :arm => [File.join(root, 'bin', 'arm')]}

                supports = [:x86, :x86_64, :arm]

                [name, version, root, includes, libraries, binaries, supports]
              when 10.0
                name, root = self._find_kit_via_registry(version)
                return nil if root.nil?

                # HACK(mtwilliams): Determine the latest and greatest version
                # by finding the directory with the highest version number. We
                # should look into using the 'PlatformIdentity' attribute in SDKManifest.xml.
                version = Dir.entries(File.join(root, 'lib')).sort.last

                includes = [File.join(root, 'include', version, 'ucrt'),
                            File.join(root, 'include', version, 'shared'),
                            File.join(root, 'include', version, 'um')]
                libraries = {:x86    => [File.join(root, 'lib', version, 'ucrt', 'x86'),
                                         File.join(root, 'lib', version, 'um', 'x86')],
                             :x86_64 => [File.join(root, 'lib', version, 'ucrt', 'x64'),
                                         File.join(root, 'lib', version, 'um', 'x64')],
                                :arm => [File.join(root, 'lib', version, 'ucrt', 'arm'),
                                         File.join(root, 'lib', version, 'um', 'arm')]}
                binaries  = {:x86    => [File.join(root, 'bin', 'x86')],
                             :x86_64 => [File.join(root, 'bin', 'x64')],
                                :arm => [File.join(root, 'bin', 'arm')]}

                supports = [:x86, :x86_64, :arm]

                [name, '10.0', root, includes, libraries, binaries, supports]
              else
                # TODO(mtwilliams): Raise an exception.
                # raise VisualStudio::UnsupportedVersion.new(...)
              end

          Windows::SoftwareDevelopmentKit.new(name: name,
                                              version: version,
                                              root: root,
                                              includes: includes,
                                              libraries: libraries,
                                              binaries: binaries,
                                              supports: supports)
        else
          # TODO(mtwilliams): Raise an exception.
          # raise VisualStudio::InvalidVersion.new(...)
        end
      end

      private
        def self._find_via_registry(version)
          # We try to find an embedded version of the SDK. If we can't, then
          # we look for standalone verions. They appear interchangeable, but
          # this requires further testing to confirm.
          keys = ["SOFTWARE\\Wow6432Node\\Microsoft\\Microsoft SDKs\\Windows\\v#{version}A",
                  "SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\v#{version}A",
                  "SOFTWARE\\Wow6432Node\\Microsoft\\Microsoft SDKs\\Windows\\v#{version}",
                  "SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\v#{version}"]
          installs = keys.map do |key|
            begin
              require 'win32/registry'
              key = ::Win32::Registry::HKEY_LOCAL_MACHINE.open(key, ::Win32::Registry::KEY_READ)
              [key['ProductName'], File.expand_path(key['InstallationFolder']).to_s]
            rescue
            end
          end
          installs.compact.first
        end

        def self._find_kit_via_registry(version)
          # There's no easy way to pull names out of the registry.
          names = {'10.0' => "Windows Kit for Universal Windows",
                   '8.1'  => "Windows Kit for Windows 8.1",
                   '8.0'  => "Windows Kit for Windows 8.0"}
          keys = ["SOFTWARE\\Wow6432Node\\Microsoft\\Windows Kits\\Installed Roots",
                  "SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots"]
          # For some reason, Microsoft has decided to use properties instead of
          # distinct keys for Windows Kits. Yet another case of them being
          # unable to make up their minds.
          properties = {'10.0' => "KitsRoot10",
                        '8.1'  => "KitsRoot81",
                        '8.0'  => "KitsRoot"}
          installs = keys.map do |key|
            begin
              require 'win32/registry'
              root = ::Win32::Registry::HKEY_LOCAL_MACHINE.open(key, ::Win32::Registry::KEY_READ)[properties[version]]
              File.expand_path(root).to_s
            rescue
            end
          end
          [names[version], installs.compact.first]
        end
    end
  end
end
