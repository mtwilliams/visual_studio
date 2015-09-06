module VisualStudio
  class Install
    attr_reader :name
    attr_reader :version
    attr_reader :root
    attr_reader :toolsets
    attr_reader :sdks

    def initialize(opts={})
      @name = opts[:name]
      @version = opts[:version]
      @root = opts[:root]
      @toolsets = opts[:toolsets]
      @sdks = opts[:sdks]
    end

    def self.exists?(name_or_version)
      !!(find(name_or_version))
    end

    def self.find(name_or_version)
      return find_by_name(name_or_version) if NAMES.include?(name_or_version)
      return find_by_version(name_or_version) if VERSIONS.include?(name_or_version)
    end

    def self.find_by_name(name)
      find_by_version(NAME_TO_VERSION[name]) if NAMES.include?(name)
    end

    def self.find_by_version(version)
      install = _find_install_via_registry(version)
      return if install.nil?

      # HACK(mtwilliams): Assume C/C++ is installed.
      c_and_cpp = File.join(install, 'VC')
      # TODO(mtwilliams): Search for other toolsets, notably C#.
      csharp = nil # File.join(install, 'VC#')

      # TODO(mtwilliams): Look for SDKs, including packaged ones.
      sdk = nil # ...

      # TODO(mtwilliams): Cache.
      VisualStudio::Install.new(name: VERSION_TO_NAME[version],
                                version: version,
                                root: install,
                                toolsets: Hashie::Mash.new({
                                  c: c_and_cpp,
                                  cpp: c_and_cpp,
                                  csharp: csharp }),
                                sdks: Hashie::Mash.new({
                                  windows: nil }))
    end

    private
      def self._find_install_via_registry(version)
        # TODO(mtwilliams): Try other products, like C#.
        keys = ["SOFTWARE\\Microsoft\\VisualStudio\\#{version}\\Setup\\VC",
                "SOFTWARE\\Wow6432Node\\Microsoft\\VisualStudio\\#{version}\\Setup\\VC"]
        keys.each do |key|
          begin
            require 'win32/registry'
            return File.expand_path(File.join(::Win32::Registry::HKEY_LOCAL_MACHINE.open(key, ::Win32::Registry::KEY_READ)['ProductDir'], '..')).to_s
          rescue
            return nil
          end
        end
      end
  end
end
