module StyleCop
  class StyleGuide
    def initialize(styleguide, selector)
      @styleguide = styleguide
      @selector = selector
    end

    def element
      Selector.new(styleguide.find("#{selector.key}.style-cop-pattern"))
    end

    private

    attr_reader :styleguide, :selector
  end
end
