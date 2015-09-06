# Visual Studio

[![Gem Version](https://img.shields.io/gem/v/visual_studio.svg)](https://rubygems.org/gems/visual_studio)
[![Build Status](https://img.shields.io/travis/mtwilliams/visual_studio/master.svg)](https://travis-ci.org/mtwilliams/visual_studio)
[![Code Climate](https://img.shields.io/codeclimate/github/mtwilliams/visual_studio.svg)](https://codeclimate.com/github/mtwilliams/visual_studio)
[![Dependency Status](https://img.shields.io/gemnasium/mtwilliams/visual_studio.svg)](https://gemnasium.com/mtwilliams/visual_studio)

This will (hopefully) become the de-facto gem for inspecting Visual Studio installs and generating Visual Studio project files. It was created for [Ryb](https://github.com/mtwilliams/ryb), a project file generator similar to Premake.

Documentation is on the back-burner, so for now:

```ruby
VisualStudio.available? # true
install = VisualStudio.find 'vs2015'
install.name.pretty # "Visual Studio 2015"
install.name # "vs2015"
install.version # "14.0"
install.root # "C:/Program Files (x86)/Microsoft Visual Studio 14.0/"
```
