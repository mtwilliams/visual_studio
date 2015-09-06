$:.push File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
require 'visual_studio/gem/version'

Gem::Specification.new do |s|
  s.name              = 'visual_studio'
  s.version           = VisualStudio::Gem.version
  s.platform          = Gem::Platform::RUBY
  s.author            = 'Michael Williams'
  s.email             = 'm.t.williams@live.com'
  s.homepage          = 'https://github.com/mtwilliams/visual_studio'
  s.summary           = 'Inspect Visual Studio installs and generate Visual Studio project files.'
  s.description       = 'This will (hopefully) become the de-facto gem for inspecting Visual Studio installs and generating Visual Studio project files.'
  s.license           = 'Public Domain'

  s.required_ruby_version = '>= 1.9.3'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w(lib)

  s.add_dependency 'hashie'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'
end
