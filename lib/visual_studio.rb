require 'hashie'

class VisualStudio
  NAMES           = ['vs2015', 'vs2013', 'vs2012', 'vs2010', 'vs2008', 'vs2005', 'vs2003', 'vs2002', 'vs6']
  PRETTY_NAMES    = ['Visual Studio 2015', 'Visual Studio 2013', 'Visual Studio 2012', 'Visual Studio 2010',
                     'Visual Studio 2008', 'Visual Studio 2005', 'Visual Studio .NET 2003', 'Visual Studio 6.0']
  VERSIONS        = ['14.0', '12.0', '11.0', '10.0', '9.0', '8.0', '7.1', '7.0', '6.0']
  NAME_TO_VERSION = Hash[NAMES.zip(VERSIONS)]
  NAME_TO_PRETTY_NAME = Hash[NAMES.zip(PRETTY_NAMES)]
  VERSION_TO_NAME = Hash[VERSIONS.zip(NAMES)]

  attr_reader :name
  attr_reader :version
  attr_reader :install
  attr_reader :toolsets
  attr_reader :sdks

  def initialize(opts={})
    require 'visual_studio/name'
    @name = VisualStudio::Name.new(opts[:name], pretty: NAME_TO_PRETTY_NAME[opts[:name]])
    @version = opts[:version]
    @install = opts[:install]
    @toolsets = opts[:toolsets]
    @sdks = opts[:sdks]
  end

  def self.available?
    VERSIONS.any? { |version| installed?(version) }
  end

  def self.installed?(name_or_version)
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
    VisualStudio.new(name: VERSION_TO_NAME[version],
                     version: version,
                     install: install,
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
