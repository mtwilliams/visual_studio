# Visual Studio

[![Gem Version](https://img.shields.io/gem/v/visual_studio.svg)](https://rubygems.org/gems/visual_studio)
[![Build Status](https://img.shields.io/travis/mtwilliams/visual_studio/master.svg)](https://travis-ci.org/mtwilliams/visual_studio)
[![Code Climate](https://img.shields.io/codeclimate/github/mtwilliams/visual_studio.svg)](https://codeclimate.com/github/mtwilliams/visual_studio)
[![Dependency Status](https://img.shields.io/gemnasium/mtwilliams/visual_studio.svg)](https://gemnasium.com/mtwilliams/visual_studio)

This will (hopefully) become the de-facto gem for inspecting Visual Studio installs and generating Visual Studio project files. It was created for [Ryb](https://github.com/mtwilliams/ryb), a project file generator similar to Premake.

Documentation is on the back-burner, so for now:

```Ruby

VisualStudio.available?
VisualStudio.installed?
 => true

VisualStudio.available? 'vs2015'
VisualStudio.installed? 'vs2015'
 => true

VisualStudio.latest
VisualStudio.install
 => #<VisualStudio::Install @name=#<VisualStudio::Helpers::Name "vs2015" @pretty=""Visual Studio 2015"> ...>

VisualStudio.install 'vs2015'
VisualStudio.find 'vs2015'
VisualStudio.find_by(name: 'vs2015')
VisualStudio.find_by_name 'vs2015'
VisualStudio.find_by(version: 'vs2015')
VisualStudio.find_by_version '14.0'
 => #<VisualStudio::Install @name=#<VisualStudio::Helpers::Name "vs2015" @pretty="Visual Studio 2015"> ...>

vs = VisualStudio.latest
vs.name
 => "vs2015"
vs.name.pretty
 => "vs2015"
vs.version
 => "14.0"
vs.root
 => "C:/Program Files (x86)/Microsoft Visual Studio 14.0"
vs.suite[:c_and_cpp]
vs.products[:c_and_cpp]
 => #<VisualStudio::Product @name=#<VisualStudio::Helpers::Name "VC" @pretty="Microsoft Visual C/C++"> ...>
vs.suite[:csharp]
vs.products[:csharp]
 => #<VisualStudio::Product @name=#<VisualStudio::Helpers::Name "VC" @pretty="Microsoft Visual C#"> ...>

vc = vs.products[:c_and_cpp]
vc.name
 => "VC"
vc.name.pretty
 => "Microsoft Visual C/C++"
vc.version
 => "14.0"
vc.root
 => "C:/Program Files (x86)/Microsoft Visual Studio 14.0/VC"
vc.paths.includes
 => {:x86 => ..., :x86_64 => ...}
vc.paths.libraries
 => {:x86 => ..., :x86_64 => ...}
vc.sdks
 => {:windows => ...}
vc.platforms
 => [:windows]
vc.architectures
 => [:x86, :x86_64]
vc.supports? :windows
 => true
vc.supports? :arm
 => false
env = vc.environment target: {platform: :windows,
                                  arch: :x86_64},
                     base: ENV
=> {"PATH" => "...", ...}
```
