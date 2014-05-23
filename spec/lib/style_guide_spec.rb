require 'spec_helper'

module StyleCop
  describe StyleGuide do
    describe "#find" do
      let(:styleguide_html) do
        create_html({
          body: %{
            <div class="selector first style-cop-pattern"></div>
            <div class="selector second style-cop-pattern"></div>
          }
        })
      end

      let(:styleguide_page) { FakePage.new(styleguide_html) }
      let(:styleguide) { StyleGuide.new(styleguide_page) }

      it "finds elements in the styleguide by key" do
        expect(styleguide.find(".selector.first").key).to eq(".selector.first")
      end
    end
  end
end
