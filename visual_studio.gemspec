$:.push File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
require 'visual_studio/gem'

Gem::Specification.new do |s|
  # This information has been refactored into `lib/visual_studio/gem.lib`.
  s.name              = VisualStudio::Gem.name
  s.version           = VisualStudio::Gem.version
  s.platform          = Gem::Platform::RUBY
  s.author            = VisualStudio::Gem.author.name
  s.email             = VisualStudio::Gem.author.email
  s.homepage          = VisualStudio::Gem.homepage
  s.summary           = VisualStudio::Gem.summary
  s.description       = VisualStudio::Gem.description
  s.license           = VisualStudio::Gem.license

  s.required_ruby_version = '>= 2.0.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w(lib)

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'
end
