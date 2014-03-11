require "spec_helper"

describe StyleCop do
  context "capybara driver" do
    it "doesn't change the current driver by default" do
      expect(Capybara.current_driver).to_not eq(:webkit)
    end

    it "changes to current driver for style cop specs", style_cop: true do
      expect(Capybara.current_driver).to eq(:webkit)
    end
  end

  context "styleguide_page" do
    it "doesn't add the helper method for non-style cop tests" do
      expect(self).to_not respond_to(:styleguide_page)
    end

    context "style cop tests", style_cop: true do
      it "have a styleguide_page method" do
        Capybara.app = FakePage::TestApp
        Capybara.app.set_html("<html></html>")
        expect(styleguide_page("/")).to_not be_nil
      end
    end
  end
end
