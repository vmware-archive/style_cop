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

        context "for an element with just the class '.style-cop-pattern" do
          let(:selector_html) do
            create_html(body: "<span class='style-cop-pattern' id='not_ignored'></span>")
          end

          it "does not return the style-cop-pattern class as the key" do
            expect(selector.key).to eq("#not_ignored")
          end
        end

        context "for an element with the '.style-cop-pattern' class and another class" do
          let(:selector_html) do
            create_html(body: "<span class='style-cop-pattern something-else' id='ignored'></span>")
          end

          it "removes 'style-cop-pattern' from the key" do
            expect(selector.key).to eq(".something-else")
          end
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

    describe "#full_style_representation" do
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

      it "returns a hash with structure keys and css values" do
        expect(selector.full_style_representation.keys.sort).to eq(
          [".selector", ".selector .child1", ".selector .child1 .child3", ".selector .child2"]
        )
        expect(selector.full_style_representation[".selector"]["font-size"]).to eq("16px")
        expect(selector.full_style_representation[".selector .child1"]["font-size"]).to eq("24px")
        expect(selector.full_style_representation[".selector .child1 .child3"]["font-size"]).to eq("36px")
        expect(selector.full_style_representation[".selector .child2"]["font-size"]).to eq("16px")
      end
    end

    describe "#relevant_style_representation" do
      let(:html) do
        create_html({
          style: %{
            .child3 { color: red }
          },
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
      let(:selector) { Selector.new page.find(".child3") }

      it "returns a hash with structure keys and css values" do
        expect(selector.relevant_style_representation.keys.sort).to eq(
          [".child3"]
        )
        expect(selector.relevant_style_representation['.child3'].keys.length).to eq 1
        expect(selector.relevant_style_representation['.child3']['color']).to eq 'rgb(255, 0, 0)'
      end

      context "there is no css" do
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

        it "returns a hash with structure keys and no css values" do
          expect(selector.relevant_style_representation['.child3'].keys.length).to eq 0
        end
      end
    end
  end
end
