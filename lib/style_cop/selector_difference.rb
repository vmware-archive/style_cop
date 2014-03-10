module StyleCop
  class SelectorDifference
    MISSING_CSS_TEXT = "element is missing the following css"
    EXTRA_CSS_TEXT = "element has the following extra css"
    MISSING_STRUCTURE_TEXT = "element is missing the following structure piece"
    EXTRA_STRUCTURE_TEXT = "element has the following extra structure piece"

    def initialize(selector, other_selector)
      @selector = selector
      @other_selector = other_selector
    end

    def empty?
      selector.computed_style == other_selector.computed_style &&
        selector.structure == other_selector.structure &&
        selector.children == other_selector.children
    end

    def error_message
      (css_errors + structure_errors).join(", ")
    end

    private

    attr_reader :selector, :other_selector

    def structure_errors
      extra = structure_difference(other_selector, selector)
      extra = "The #{selector.key} #{EXTRA_STRUCTURE_TEXT}: #{extra}" if extra
      missing = structure_difference(selector, other_selector)
      missing = "The #{selector.key} #{MISSING_STRUCTURE_TEXT}: #{missing}" if missing
      errors = [extra, missing].compact
      errors.empty? ? [] : [errors.join(", ")]
    end

    def css_errors
      extra = css_difference(other_selector, selector)
      extra = "The #{selector.key} #{EXTRA_CSS_TEXT}: #{extra}" if extra
      missing = css_difference(selector, other_selector)
      missing = "The #{selector.key} #{MISSING_CSS_TEXT}: #{missing}" if missing
      errors = [missing, extra].compact
      errors.empty? ? [] : [errors.join(", ")]
    end

    def css_difference(test_case, styleguide)
      difference = (Hash[styleguide.computed_style.to_a - test_case.computed_style.to_a]).
        map{|k,v| "#{k}: #{v}"}.join(', ')
      difference.empty? ? nil :difference
    end

    def structure_difference(test_case, styleguide)
      difference = (styleguide.structure.values.flatten - test_case.structure.values.flatten).
        map(&:keys).flatten.join(', ')
      difference.empty? ? nil : difference
    end
  end
end
