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
        selector = Selector.new(page.find('.selector.first'))
        expect(selector.computed_style["font-size"]).to eq("4px")
      end

      it "returns the correct style for elements with the same class" do
        selector = Selector.new(page.find('.selector.second'))
        expect(selector.computed_style["font-size"]).to eq("6px")
      end

      context "excluded keys" do
        let(:selector) { Selector.new(page.find(".selector.first")) }
        subject { selector.computed_style }

        it { should_not have_key("width") }
        it { should_not have_key("height") }
        it { should_not have_key("top") }
        it { should_not have_key("bottom") }
        it { should_not have_key("right") }
        it { should_not have_key("left") }
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

    describe "#==" do
      let(:selector) { Selector.new(double) }

      before do
        allow(SelectorDifference).to receive(:new).and_return(selector_difference)
      end

      context "an emtpy selector difference" do
        let(:selector_difference) { double(SelectorDifference, empty?: true) }

        it "returns true" do
          expect(selector).to eq double(Selector)
        end
      end

      context "a non empty selector difference" do
        let(:selector_difference) { double(SelectorDifference, empty?: false) }

        it "returns false" do
          expect(selector).to_not eq double(Selector)
        end
      end
    end

    describe "#structure" do
      let(:html) do
        create_html({
          body: %{
              <div class="selector style-cop-pattern">
                <div class="child1">
                  <div class="child3 style-cop-pattern"></div>
                </div>
                <div class="child2"></div>
              </div>
          }
        })
      end

      let(:page) { FakePage.new(html) }
      let(:selector) { Selector.new page.find(".selector") }

      it "returns a hash with its key and children" do
        expect(selector.structure).to eq({
          ".selector" => [
            {".child1" => [{".child3" => [] }]},
            {".child2" => []}
          ]
        })
      end
    end
  end
end
