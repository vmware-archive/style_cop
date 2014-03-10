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
      let(:first_selector) { Selector.new page.find(".selector.first") }
      let(:last_selector) { Selector.new page.find(".selector.second") }
      let(:page) { FakePage.new(html) }

      context "when two selectors have same css" do
        let(:html) do
          create_html({
            body: %{
              <div class="selector first"></div>
              <div class="selector second"></div>
            }
          })
        end

        it "returns true" do
          expect(first_selector).to eq(last_selector)
        end
      end

      context "when two selectors don't have same css" do
        let(:html) do
          create_html({
            body: %{
              <div class="selector first"></div>
              <div class="selector second" style="font-size: 100px"></div>
            }
          })
        end

        it "returns false" do
          expect(first_selector).to_not eq(last_selector)
        end
      end
    end
  end
end
