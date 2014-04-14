require 'spec_helper'

describe "something", style_cop: true do
  it "shows something" do
    visit "http://localhost:4567"
    selector = page.find(".simple-pattern")
    expect(selector).to match_styleguide(styleguide_page("http://localhost:4567/style-guide"))
  end
end

