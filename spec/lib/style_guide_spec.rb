require 'spec_helper'

module StyleCop
  describe StyleGuide do
    describe "#element" do
      let(:styleguide_html) do
        create_html({
          body: %{
            <div class="selector first style-cop-pattern"></div>
            <div class="selector second style-cop-pattern"></div>
          }
        })
      end
      let(:selector_html) do
        create_html({
          body: %{
            <div class="selector first"></div>
            <div class="selector second"></div>
          }
        })
      end
      let(:styleguide_page) { FakePage.new(styleguide_html) }
      let(:selector) { FakePage.new(selector_html).find('.selector.first') }
      let(:styleguide) { StyleGuide.new(styleguide_page, selector) }

      before do
        allow(selector).to receive(:key) { '.selector.first' }
      end

      it "is the selected element from the styleguide page" do
        expect(Selector).to receive(:new).with(styleguide_page.find('.selector.first'))
        styleguide.element
      end
    end
  end
end
