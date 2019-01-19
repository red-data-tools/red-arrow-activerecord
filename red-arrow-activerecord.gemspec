$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "arrow-activerecord/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "red-arrow-activerecord"
  s.version     = ArrowActiverecord::VERSION
  s.authors     = ["hatappi", "Kouhei Sutou"]
  s.email       = ["hatappi@hatappi.me", "kou@clear-code.com"]
  s.homepage    = "https://github.com/red-data-tools/red-arrow-activerecord"
  s.summary     = "A library that provides conversion method between Apache Arrow and ActiveRecord"
  s.description = "A library that provides conversion method between Apache Arrow and ActiveRecord"
  s.license     = "MIT"

  s.files = Dir["{lib,doc}/**/*", "LICENSE", "Rakefile", "README.md"]

  s.add_dependency "activerecord"
  s.add_dependency "red-arrow", ">= 0.12.0"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "test-unit"
end
