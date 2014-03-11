module StyleCop
  module Helpers
    def styleguide_page(path)
      old_session_name = Capybara.session_name
      Capybara.session_name = "styleguide"
      Capybara.visit path
      Capybara.page.tap { Capybara.session_name = old_session_name }
    end
  end
end

RSpec.configure do |config|
  config.include(StyleCop::Helpers, style_cop: true)
end
