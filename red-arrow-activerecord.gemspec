$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "red/arrow/activerecord/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "red-arrow-activerecord"
  s.version     = Red::Arrow::Activerecord::VERSION
  s.authors     = ["hatappi"]
  s.email       = ["hatappi@hatappi.me"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Red::Arrow::Activerecord."
  s.description = "TODO: Description of Red::Arrow::Activerecord."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.4"

  s.add_development_dependency "mysql2"
end
