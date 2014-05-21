Gem::Specification.new do |s|
  s.name        = 'style_cop'
  s.version     = '0.0.4'
  s.date        = '2014-03-13'
  s.summary     = "Gem for testing style"
  s.description = "Gem for testing style"
  s.authors     = ["Ward Penney", "David Tengdin", "Jordi Noguera"]
  s.email       = 'commoncode@pivotallabs.com'
  s.files       = `git ls-files`.split("\n")
  s.homepage    = 'http://rubygems.org/gems/style_cop'
  s.license     = 'MIT'

  s.add_dependency "rspec"
  s.add_dependency "capybara-webkit"

  s.add_development_dependency "pry"
  s.add_development_dependency "sinatra"
  s.add_development_dependency "haml"
end
