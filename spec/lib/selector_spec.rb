require "spec_helper"

module StyleCop
  describe Selector, style_cop: true do
    describe "#computed_style" do
      let(:page) { FakePage.new(html) }

      let(:html) do
        create_html({
          style: %{
            .selector { font-size: 4px; }
            .selector.second { font-size: 6px; }
          },
            body: %{
            <div class="selector first"></div>
            <div class="selector second"></div>
          }
        })
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

    describe "#key" do
      let(:page) { FakePage.new(selector_html) }
      let(:capybara_selector) { page.find("span") }
      let(:selector) { Selector.new(capybara_selector) }

      context "for a class" do
        let(:selector_html) do
          create_html(body: "<span class='selector other-selector' id='ignored'></span>")
        end

        it "returns the classes separated by a dot" do
          expect(selector.key).to eq(".selector.other-selector")
        end
      end

      context "for an id" do
        let(:selector_html) do
          create_html(body: "<span id='selector'></span>")
        end

        it "returns the id prefixed by a pound" do
          expect(selector.key).to eq("#selector")
        end
      end

      context "for an html element" do
        let(:selector_html) do
          create_html(body: "<span></span>")
        end

        it "returns html element" do
          expect(selector.key).to eq("span")
        end
      end
    end
  end
end
