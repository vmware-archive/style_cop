require 'rubygems'
require 'bundler/setup'

require 'pry'
require 'style_cop'
require 'rspec'
require 'capybara'

ENV['test_run'] = true.to_s

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each do |file|
  require file
end

RSpec.configure do |config|
  config.mock_with :rspec
end
