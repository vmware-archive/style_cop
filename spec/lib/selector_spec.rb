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
      let(:first_selector) { Selector.new page.all(".selector").first }
      let(:last_selector) { Selector.new page.all(".selector").last }
      let(:page) { FakePage.new(html) }

      context "when two selectors have same css" do
        let(:html) do
          create_html({
            body: %{
              <div class="selector"></div>
              <div class="selector"></div>
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
              <div class="selector"></div>
              <div class="selector" style="font-size: 100px"></div>
            }
          })
        end

        it "returns false" do
          expect(first_selector).to_not eq(last_selector)
        end
      end

      context "when two selectors have same structure" do
        let(:html) do
          create_html({
            body: %{
              <div class="selector"><div class="child2"></div></div>
              <div class="selector"><div class="child2"></div></div>
            }
          })
        end

        it "returns true" do
          expect(first_selector).to eq(last_selector)
        end
      end

      context "when two selectors don't have same structure" do
        let(:html) do
          create_html({
            body: %{
              <div class="selector"></div>
              <div class="selector"><div class="child2"></div></div>
            }
          })
        end

        it "returns false" do
          expect(first_selector).to_not eq(last_selector)
        end
      end

      context "when two selectors children have same css" do
        let(:html) do
          create_html({
            body: %{
              <div class="selector"><div class="child2"></div></div>
              <div class="selector"><div class="child2"></div></div>
            }
          })
        end

        it "returns false" do
          expect(first_selector).to eq(last_selector)
        end
      end

      context "when two selectors children don't have same css" do
        let(:html) do
          create_html({
            body: %{
              <div class="selector"><div class="child2"></div></div>
              <div class="selector"><div class="child2" style="font-size:100px"></div></div>
            }
          })
        end

        it "returns false" do
          expect(first_selector).to_not eq(last_selector)
        end
      end
    end

    describe "#structure" do
      let(:html) do
        create_html({
          body: %{
              <div class="selector">
                <div class="child1">
                  <div class="child3"></div>
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
