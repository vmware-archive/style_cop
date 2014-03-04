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

  s.add_development_dependency "rspec", "~> 2.14.0"
  s.add_development_dependency "xpath", "~> 2.0.0"
  s.add_development_dependency "pry", "~> 0.9.12.6"
end
