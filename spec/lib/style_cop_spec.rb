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
end
