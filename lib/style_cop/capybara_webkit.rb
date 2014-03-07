RSpec.configure do |config|
  config.before(:each, type: :style_cop) do
    Capybara.current_driver = :webkit
  end

  config.after(:each, type: :style_cop) do
    Capybara.use_default_driver
  end
end

