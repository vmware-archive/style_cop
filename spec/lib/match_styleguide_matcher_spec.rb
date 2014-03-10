require 'spec_helper'

module StyleCop
  describe "MatchStyleguideMatcher" do
    it "includes the matcher" do
      expect(self).to respond_to(:match_styleguide)
    end

    context "when the selectors matches the styleguide" do
      let(:html) do
        create_html({
          body: %(
            <div class='selector'></div>
            <div class='selector style-cop-pattern'></div>
          )
        })
      end
      let(:page) { FakePage.new(html) }
      let(:selector) { page.all(".selector").first }

      it "passes" do
        expect(selector).to match_styleguide(page)
      end
    end

    context "when the selector doesn't match the styleguide" do
      let(:html) do
        create_html({
          body: %(
            <div class='selector'></div>
            <div class='selector style-cop-pattern'><div class='wrong'></div></div>
          )
        })
      end

      let(:page) { FakePage.new(html) }
      let(:selector) { page.all(".selector").first }
      let(:styleguide_selector) { page.find(".selector.style-cop-pattern") }
      let(:selector_difference) { double(SelectorDifference, empty?: false) }

      it "doesn't pass" do
        expect(selector).to_not match_styleguide(page)
      end

      it "displays error messages when matcher fails" do
        allow(SelectorDifference).to receive(:new).
          and_return(selector_difference)
        expect(selector_difference).to receive(:error_message) { "selector to match" }

        expect {
          expect(selector).to match_styleguide(page)
        }.to raise_error(/selector to match/)
      end
    end
  end
end
