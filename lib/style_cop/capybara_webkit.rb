RSpec.configure do |config|
  config.before(:each, style_cop: true) do
    Capybara.current_driver = :webkit
  end

  config.after(:each, style_cop: true) do
    Capybara.use_default_driver
  end
end
