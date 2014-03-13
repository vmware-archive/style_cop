require "spec_helper"

module StyleCop
  describe Selector, style_cop: true do
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

    describe "#representation" do
      let(:html) do
        create_html({
          body: %{
              <div class="selector style-cop-pattern" style="font-size:16px">
                <div class="child1" style="font-size:24px">
                  <div class="child3 style-cop-pattern" style="font-size:36px"></div>
                </div>
                <div class="child2"></div>
              </div>
          }
        })
      end

      let(:page) { FakePage.new(html) }
      let(:selector) { Selector.new page.find(".selector") }

      it "returns a hash with structure keys andd css values" do
        expect(selector.representation.keys.sort).to eq(
          [".selector", ".selector .child1", ".selector .child1 .child3", ".selector .child2"]
        )
        expect(selector.representation[".selector"]["font-size"]).to eq("16px")
        expect(selector.representation[".selector .child1"]["font-size"]).to eq("24px")
        expect(selector.representation[".selector .child1 .child3"]["font-size"]).to eq("36px")
        expect(selector.representation[".selector .child2"]["font-size"]).to eq("16px")
      end

      context "excluded keys in style" do
        let(:html) do
          create_html({
            body: %{
                <div class="selector"></div>
            }
          })
        end

        let(:selector) { Selector.new(page.find(".selector")) }
        subject { selector.representation['.selector'] }

        it { should_not have_key("width") }
        it { should_not have_key("height") }
        it { should_not have_key("top") }
        it { should_not have_key("bottom") }
        it { should_not have_key("right") }
        it { should_not have_key("left") }
        it { should_not have_key("-webkit-perspective-origin") }
        it { should_not have_key("-webkit-transform-origin") }
      end
    end
  end
end
