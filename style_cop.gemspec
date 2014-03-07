Gem::Specification.new do |s|
  s.name        = 'style_cop'
  s.version     = '0.0.1'
  s.date        = '2014-03-03'
  s.summary     = "Gem for testing style"
  s.description = "Gem for testing style"
  s.authors     = ["Ward Penney", "David Tengdin"]
  s.email       = 'style-cop@googlegroups.com'
  s.files       = `git ls-files`.split("\n")
  s.homepage    = 'http://rubygems.org/gems/style_cop'
  s.license     = 'MIT'

  s.add_dependency "rspec"
  s.add_dependency "capybara-webkit"

  s.add_development_dependency "pry"
  s.add_development_dependency "sinatra"
end
