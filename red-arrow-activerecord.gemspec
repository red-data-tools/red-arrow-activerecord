$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "arrow-activerecord/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "red-arrow-activerecord"
  s.version     = ArrowActiverecord::VERSION
  s.authors     = ["hatappi"]
  s.email       = ["hatappi@hatappi.me"]
  s.homepage    = "https://github.com/red-data-tools/red-arrow-activerecord"
  s.summary     = "A library that provides conversion method between Apache Arrow and ActiveRecord"
  s.description = "A library that provides conversion method between Apache Arrow and ActiveRecord"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.4"

  s.add_development_dependency "mysql2"
end
