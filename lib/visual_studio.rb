module VisualStudio
  NAMES        = ['vs2015', 'vs2013', 'vs2012', 'vs2010', 'vs2008', 'vs2005']

  PRETTY_NAMES = ['Visual Studio 2015', 'Visual Studio 2013',
                  'Visual Studio 2012', 'Visual Studio 2010',
                  'Visual Studio 2008', 'Visual Studio 2005']

  VERSIONS     = [14.0, 12.0, 11.0, 10.0, 9.0, 8.0].map(&:to_s)

  SDKS         = [{windows:  %w{10.0 8.1 8.0 7.1}},
                  {windows:       %w{8.1 8.0 7.1}},
                  {windows:       %w{8.1 8.0 7.1}},
                  {windows:       %w{8.1 8.0 7.1}},
                  {windows:               %w{7.1 7.0}},
                  {windows:               %w{7.1 7.0}}]

  NAME_TO_VERSION = Hash[NAMES.zip(VERSIONS)]
  VERSION_TO_NAME = Hash[VERSIONS.zip(NAMES)]

  NAME_TO_PRETTY_NAME = Hash[NAMES.zip(PRETTY_NAMES)]
  VERSION_TO_PRETTY_NAME = Hash[VERSIONS.zip(PRETTY_NAMES)]

  NAME_TO_SDKS = Hash[NAMES.zip(SDKS)]
  VERSION_TO_SDKS = Hash[VERSIONS.zip(SDKS)]

  require 'visual_studio/helpers/pretty_string'

  require 'visual_studio/install'
  require 'visual_studio/product'

  def self.available?(name_or_version=nil)
    self.installed?(name_or_version)
  end

  def self.installed?(name_or_version=nil)
    if name_or_version
      VisualStudio::Install.available?(name_or_version)
    else
      VisualStudio::VERSIONS.any?{|version| VisualStudio.installed?(version)}
    end
  end

  def self.install(name_or_version=nil)
    if name_or_version
      self.find(name_or_version)
    else
      self.latest
    end
  end

  def self.latest
    VisualStudio::Install.latest
  end

  def self.find(name_or_version)
    VisualStudio::Install.find(name_or_version)
  end

  def self.find_by(criteria)
    VisualStudio::Install.find_by(criteria)
  end

  def self.find_by_name(name)
    VisualStudio::Install.find_by_name(name)
  end

  def self.find_by_version(version)
    VisualStudio::Install.find_by_version(name)
  end
end
