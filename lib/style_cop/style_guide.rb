module StyleCop
  class StyleGuide
    def initialize(styleguide)
      @styleguide = styleguide
    end

    def find(selector_key)
      Selector.new(styleguide.find("#{selector_key}.style-cop-pattern"))
    end

    private

    attr_reader :styleguide
  end
end
