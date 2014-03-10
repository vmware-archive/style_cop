require 'spec_helper'

module StyleCop
  describe SelectorDifference do
    let(:selector) { double }
    let(:styleguide_selector) { double }
    subject { SelectorDifference.new(selector, styleguide_selector) }

    describe "#error_message" do 
      before do
        allow(selector).to receive(:key).and_return(".structure")
        allow(selector).to receive(:computed_style).and_return(selector_css)
        allow(selector).to receive(:structure).and_return(selector_structure)
        allow(styleguide_selector).to receive(:computed_style).and_return(styleguide_css)
        allow(styleguide_selector).to receive(:structure).and_return(styleguide_structure)
      end

      context "css" do
        let(:selector_structure) { {".selector" => []} }
        let(:styleguide_structure) { {".selector" => []} }

        context "missing styleguide css" do
          let(:selector_css) { {"a"=>"b"} }
          let(:styleguide_css) { {"a"=>"b", "font-size"=>"100px"} }

          it "shows what css the element is missing" do
            message = "The .structure element is missing the following css: font-size: 100px"
            expect(subject.error_message).to eq message
          end
        end

        context "extra css not in styleguide" do
          let(:selector_css) { {"a"=>"b", "font-size"=>"100px"} }
          let(:styleguide_css) { {"a"=>"b"} }

          it "shows what extra css is present" do
            message = "The .structure element has the following extra css: font-size: 100px"
            expect(subject.error_message).to eq message
          end
        end

        context "missing css in the styleguide and has extra css not in the styleguide" do
          let(:selector_css) { {"a"=>"b", "font-size"=>"100px"} }
          let(:styleguide_css) { {"a"=>"b", "font-size"=>"80px"} }

          it "shows what extra css is present" do
            message = "The .structure element is missing the following css: font-size: 80px, The .structure element has the following extra css: font-size: 100px"
            expect(subject.error_message).to eq message
          end
        end
      end

      context "structure" do
        let(:selector_css) { {"a"=>"b"} }
        let(:styleguide_css) { {"a"=>"b"} }

        context "missing styleguide structure" do
          let(:selector_structure) { {".selector" => []} }
          let(:styleguide_structure) { {".selector" => [{".missing" => []}]} }

          it "shows what structure is missing from the element" do
            message = "The .structure element is missing the following structure piece: .missing"
            expect(subject.error_message).to eq message
          end
        end

        context "extra structure not in styleguide" do
          let(:selector_structure) { {".selector" => [{".extra" => []}]} }
          let(:styleguide_structure) { {".selector" => []} }

          it "shows what extra structure is present" do
            message = "The .structure element has the following extra structure piece: .extra"
            expect(subject.error_message).to eq message
          end
        end
      end
    end

    describe "#empty?" do
      let(:first_selector) { Selector.new page.all(".selector").first }
      let(:last_selector) { Selector.new page.all(".selector").last }
      let(:page) { FakePage.new(html) }
      subject { SelectorDifference.new(first_selector, last_selector) }

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
          expect(subject).to be_empty
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
          expect(subject).to_not be_empty
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
          expect(subject).to be_empty
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
          expect(subject).to_not be_empty
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
          expect(subject).to be_empty
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
          expect(subject).to_not be_empty
        end
      end
    end
  end
end
