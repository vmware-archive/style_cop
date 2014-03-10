require 'spec_helper'

module StyleCop
  describe SelectorDifference do
    describe "empty?" do
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
