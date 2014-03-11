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
      selector.representation == other_selector.representation
    end

    def error_message
      (css_errors + structure_errors).join(", ")
    end

    private

    attr_reader :selector, :other_selector

    def structure_errors
      errors = []
      extra_elements = selector.representation.keys - other_selector.representation.keys
      missing_elements = other_selector.representation.keys - selector.representation.keys
      errors << "The #{selector.key} #{EXTRA_STRUCTURE_TEXT}: #{extra_elements.join(", ")}" if extra_elements.any?
      errors << "The #{selector.key} #{MISSING_STRUCTURE_TEXT}: #{missing_elements.join(", ")}" if missing_elements.any?
      errors
    end

    def css_errors
      errors = []
      css_difference(other_selector, selector).each do |path, extra_css|
        errors << "The #{selector.key} #{EXTRA_CSS_TEXT}: #{extra_css.map{|k,v| "#{k}: #{v}"}.join(', ')}" unless extra_css.empty?
      end
      css_difference(selector, other_selector).each do |path, extra_css|
        errors << "The #{selector.key} #{MISSING_CSS_TEXT}: #{extra_css.map{|k,v| "#{k}: #{v}"}.join(', ')}" unless extra_css.empty?
      end
      errors
    end

    def css_difference(selector1, selector2)
      difference = {}
      selector2_representation = selector2.representation
      selector1.representation.each do |path, selector1_css|
        if selector2_css = selector2_representation[path]
          difference[path] = Hash[selector2_css.to_a - selector1_css.to_a]
        end
      end
      difference
    end
  end
end
