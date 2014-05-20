require 'spec_helper'

module StyleCop
  describe SelectorDifference do
    let(:selector) { double :selector }
    let(:styleguide_selector) { double :styleguide_selector }
    subject { SelectorDifference.new(selector, styleguide_selector) }

    describe "#error_message" do
      before do
        allow(selector).to receive(:key).and_return(".structure")
        allow(selector).to receive(:full_style_representation).and_return(selector_representation)
        allow(styleguide_selector).to receive(:relevant_style_representation).and_return(styleguide_representation)
      end

      context "missing styleguide css" do
        let(:selector_representation) { { ".selector" => {"a"=>"b"} } }
        let(:styleguide_representation) { { ".selector" => {"a"=>"b", "font-size"=>"100px"} } }

        it "shows what css the element is missing" do
          message = "The .structure element is missing the following css: font-size: 100px"
          expect(subject.error_message).to eq message
        end

        context "when a css attribute is present but has a different value" do
          let(:selector_representation) { { ".selector" => {"color"=>"red"} } }
          let(:styleguide_representation) { { ".selector" => {"color"=>"green"} } }

          it "shows the non-matching attributes" do
            message = "The .structure element is missing the following css: color: green"
            expect(subject.error_message).to eq message
          end
        end

      end

      context "structure" do
        context "missing styleguide structure" do
          let(:selector_representation) { { ".selector .child" => {} } }
          let(:styleguide_representation) { { ".selector .child" => {}, ".selector .child .missing" => {} } }

          it "shows what structure is missing from the element" do
            message = "The .structure element is missing the following structure piece: .selector .child .missing"
            expect(subject.error_message).to eq message
          end
        end

        context "extra structure not in styleguide" do
          let(:selector_representation) { { ".selector .child" => {}, ".selector .child .extra" => {} } }
          let(:styleguide_representation) { { ".selector .child" => {} } }

          it "shows what extra structure is present" do
            message = "The .structure element has the following extra structure piece: .selector .child .extra"
            expect(subject.error_message).to eq message
          end
        end
      end
    end

    describe "#conformant?" do
      let(:first_selector) { Selector.new page.all(".selector").first }
      let(:last_selector) { Selector.new page.all(".selector").last }
      let(:page) { FakePage.new(html) }
      subject { SelectorDifference.new(first_selector, last_selector) }

      context "when two selectors have same css" do
        let(:html) do
          create_html({
            style: %{
              .selector { font-size: 100px }
            },
            body: %{
              <div class="selector"></div>
              <div class="selector"></div>
            }
          })
        end

        it "returns true" do
          expect(subject).to be_conformant
        end
      end

      context "when two selectors don't have same css" do
        let(:html) do
          create_html({
            style: %{
              .selector:last-child { font-size: 100px }
            },
            body: %{
              <div class="selector"></div>
              <div class="selector"></div>
            }
          })
        end

        it "returns false" do
          expect(subject).to_not be_conformant
        end
      end

      context "when two selectors have same structure" do
        let(:html) do
          create_html({
            style: %{
              .selector { font-size: 100px }
            },
            body: %{
              <div class="selector"><div class="child2"></div></div>
              <div class="selector"><div class="child2"></div></div>
            }
          })
        end

        it "returns true" do
          expect(subject).to be_conformant
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
          expect(subject).to_not be_conformant
        end
      end

      context "when two selectors children have same css" do
        let(:html) do
          create_html({
            style: %{
              .selector .child2 { font-size: 100px; }
            },
            body: %{
              <div class="selector"><div class="child2"></div></div>
              <div class="selector"><div class="child2"></div></div>
            }
          })
        end

        it "returns false" do
          expect(subject).to be_conformant
        end
      end

      context "when two selectors children don't have same css" do
        let(:html) do
          create_html({
            style: %{
              .selector:last-child .child2 { font-size: 100px; }
            },
            body: %{
              <div class="selector"><div class="child2"></div></div>
              <div class="selector"><div class="child2"></div></div>
            }
          })
        end

        it "returns false" do
          expect(subject).to_not be_conformant
        end
      end
    end
  end
end
