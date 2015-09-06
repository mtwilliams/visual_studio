require 'hashie'

module VisualStudio
  autoload :VERSION, 'visual_studio/version'

  autoload :Name, 'visual_studio/name'
  autoload :Install, 'visual_studio/install'

  NAMES = [VisualStudio::Name.new('vs2015', pretty: 'Visual Studio 2015'),
           VisualStudio::Name.new('vs2013', pretty: 'Visual Studio 2013'),
           VisualStudio::Name.new('vs2012', pretty: 'Visual Studio 2012'),
           VisualStudio::Name.new('vs2010', pretty: 'Visual Studio 2010'),
           VisualStudio::Name.new('vs2008', pretty: 'Visual Studio 2008'),
           VisualStudio::Name.new('vs2005', pretty: 'Visual Studio 2005'),
           VisualStudio::Name.new('vs2003', pretty: 'Visual Studio .NET 2003'),
           VisualStudio::Name.new('vs2003', pretty: 'Visual Studio .NET 2002'),
           VisualStudio::Name.new('vs6', pretty: 'Visual Studio 6.0')]

  VERSIONS = %w{14.0 12.0 11.0 10.0 9.0 8.0 7.1 7.0 6.0}

  NAME_TO_VERSION = Hash[NAMES.zip(VERSIONS)]
  VERSION_TO_NAME = Hash[VERSIONS.zip(NAMES)]

  def self.available?
    VERSIONS.any? { |version| self.installed?(version) }
  end

  def self.installed?(name_or_version)
    VisualStudio::Install.exists?(name_or_version)
  end

  def self.find(name_or_version)
    VisualStudio::Install.find(name_or_version)
  end

  def self.find_by_name(name)
    VisualStudio::Install.find_by_name(name)
  end

  def self.find_by_version(version)
    VisualStudio::Install.find_by_version(version)
  end
end
