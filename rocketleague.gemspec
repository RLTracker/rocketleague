# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rocketleague/version'

Gem::Specification.new do |spec|
  spec.name          = "rocketleague"
  spec.version       = RocketLeague::VERSION
  spec.author        = "rltracker"

  spec.summary       = "Rocket League API"
  spec.description   = "Rocket League API"
  spec.homepage      = "https://github.com/rltracker/rocketleague"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
