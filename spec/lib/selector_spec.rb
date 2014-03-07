require "spec_helper"

module StyleCop
  describe Selector, style_cop: true do
    describe "#computed_style" do
      let(:page) { FakePage.new(html) }

      let(:html) do
        %{<html>
            <head>
              <style>
                .selector {
                  font-size: 4px;
                }

                .selector.second {
                  font-size: 6px;
                }
              </style>
            </head>
            <body>
              <div class="selector first"></div>
              <div class="selector second"></div>
            </body>
          </html>}
      end

      it "returns a hash containing computed style" do
        capybara_selector = page.find('.selector.first')
        selector = Selector.new(capybara_selector)
        expect(selector.computed_style["font-size"]).to eq("4px")
      end

      it "returns the correct style for elements with the same class" do
        capybara_selector = page.find('.selector.second')
        selector = Selector.new(capybara_selector)
        expect(selector.computed_style["font-size"]).to eq("6px")
      end
    end
  end
end
