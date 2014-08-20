$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "attendable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "attendable"
  s.version     = Attendable::VERSION
  s.authors     = ["Rafael Nowrotek"]
  s.email       = ["mail@benignware.com"]
  s.homepage    = "http://benignware.com"
  s.summary     = "Attendable plugin"
  s.description = "The attendable-plugin let's you invite members to a Group model and easily build rsvp actions"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4.0.3"

  s.add_development_dependency "sqlite3"
end
