module StyleCop
  class SelectorDifference
    def initialize(selector, other_selector)
      @selector = selector
      @other_selector = other_selector
    end

    def empty?
      selector.computed_style == other_selector.computed_style &&
        selector.structure == other_selector.structure &&
        selector.children == other_selector.children
    end

    private

    attr_reader :selector, :other_selector
  end
end
