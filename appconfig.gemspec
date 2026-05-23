# frozen_string_literal: true

require_relative "lib/appconfig/version"

Gem::Specification.new do |spec|
  spec.name = "appconfig"
  spec.version = AppConfig::VERSION
  spec.authors = ["Ray Parker"]
  spec.email = ["rayparkerbassplayer@gmail.com"]

  spec.summary = "A simple ENV variable wrapper with method_missing magic"
  spec.description = "AppConfig wraps ENV variable access behind clean method calls. " \
                     "Supports boolean conversion via ? suffix, default values, and type conversions."
  spec.homepage = "https://github.com/Master-Branch-Software/appconfig"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.files = Dir["lib/**/*", "LICENSE.txt", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "ostruct", ">= 0.2"

  spec.add_development_dependency "climate_control", "~> 1.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
