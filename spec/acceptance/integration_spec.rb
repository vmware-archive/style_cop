require 'spec_helper'

describe "real use cases", style_cop: true do
  include Capybara::DSL

  before(:all) do
    @old_port = Capybara.server_port
    Capybara.server_port = 4567
    Capybara.app = AcceptanceApp.new
  end

  before(:each) do
    visit "http://localhost:4567"
  end

  after(:all) do
    Capybara.server_port = @old_port
    Capybara.app = nil
  end

  it "validates elements that match the styleguide" do
    within ".caption-box-with-icon", text: /Valid caption box/ do
      valid_icon = page.find('.caption-box-icon')
      expect(valid_icon).to match_styleguide(styleguide_page("http://localhost:4567/style-guide"))
    end

    within ".caption-box-with-icon", text: /Invalid caption box with wrong color icon/ do
      invalid_icon = page.find('.caption-box-icon')
      expect(invalid_icon).to_not match_styleguide(styleguide_page("http://localhost:4567/style-guide"))
    end
  end

  it "allows the candidate to override irrelevant attributes of the gold standard" do
    big_text_with_extra_attribute = page.find(".really-big-text", text: /Really big text that happens to be blue/)
    expect(big_text_with_extra_attribute).to match_styleguide(styleguide_page("http://localhost:4567/style-guide"))
  end

  it "permits different numbers of identical children than the gold standard" do
    valid_styled_list = page.find(".styled-list", text: /which should be fine/i)
    expect(valid_styled_list).to match_styleguide(styleguide_page("http://localhost:4567/style-guide"))

    invalid_styled_list = page.find(".styled-list", text: /which isn't okay/i)
    expect(invalid_styled_list).to_not match_styleguide(styleguide_page("http://localhost:4567/style-guide"))
  end

  it "validates tags that match the styleguide" do
    valid_h1 = page.find("h1", text: /This h1 has the right styles/i)
    expect(valid_h1).to match_styleguide(styleguide_page("http://localhost:4567/style-guide"))

    invalid_h1_font_size = page.find("h1", text: /This h1 has the wrong font-size styles/i)
    expect(invalid_h1_font_size).to_not match_styleguide(styleguide_page("http://localhost:4567/style-guide"))
  end
end

