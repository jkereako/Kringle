Pod::Spec.new do |s|
  s.name        = 'Kringle'
  s.version     = '0.0.6'
  s.authors     = 'Jeff Kereakoglow'
  s.license     = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage    = 'https://github.com/jkereako/Kringle'
  s.source      = { :git => 'https://github.com/jkereako/Kringle.git', :tag => s.version }
  s.summary     = 'Simple networking for Swift'
  s.description = <<-DESC
  Kringle is a small, opinionated networking framework designed with simplicity in mind.
                     DESC

  s.ios.deployment_target  = '10.0'
  s.osx.deployment_target  = '10.12'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.swift_version = '5.0'

  s.module_name = 'Kringle'
  s.source_files = "Sources/#{s.module_name}/**/*.{swift}"
  s.dependency 'PromisesSwift', '~> 1.2.8'
end
