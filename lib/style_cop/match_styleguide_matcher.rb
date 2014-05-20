RSpec::Matchers.define :match_styleguide do |capybara_styleguide|
  match do |capybara_selector|
    selector = StyleCop::Selector.new(capybara_selector)
    styleguide = StyleCop::StyleGuide.new(capybara_styleguide)
    styleguide_selector = styleguide.find(selector.key)
    StyleCop::SelectorDifference.new(selector, styleguide_selector).conformant?
  end

  failure_message_for_should do |capybara_selector|
    selector = StyleCop::Selector.new(capybara_selector)
    styleguide = StyleCop::StyleGuide.new(capybara_styleguide)
    styleguide_selector = styleguide.find(selector.key)
    StyleCop::SelectorDifference.new(selector, styleguide_selector).error_message
  end
end
