module StyleCop
  class SelectorDifference
    MISSING_CSS_TEXT = "element is missing the following css"
    EXTRA_CSS_TEXT = "element has the following extra css"
    MISSING_STRUCTURE_TEXT = "element is missing the following structure piece"
    EXTRA_STRUCTURE_TEXT = "element has the following extra structure piece"

    def initialize(selector, gold_standard_selector)
      @selector = selector
      @gold_standard_selector = gold_standard_selector
    end

    def conformant?
      error_message.empty?
    end

    def error_message
      @error_message ||=(css_errors + structure_errors).join(", ")
    end

    private

    attr_reader :selector, :gold_standard_selector

    def structure_errors
      errors = []
      extra_elements = selector.representation.keys - gold_standard_selector.rule_based_representation.keys
      missing_elements = gold_standard_selector.rule_based_representation.keys - selector.representation.keys
      errors << "The #{selector.key} #{EXTRA_STRUCTURE_TEXT}: #{extra_elements.join(", ")}" if extra_elements.any?
      errors << "The #{selector.key} #{MISSING_STRUCTURE_TEXT}: #{missing_elements.join(", ")}" if missing_elements.any?
      errors
    end

    def css_errors
      errors = []
      css_difference(selector, gold_standard_selector).each do |path, missing_css|
        errors << "The #{selector.key} #{MISSING_CSS_TEXT}: #{missing_css.map{|k,v| "#{k}: #{v}"}.join(', ')}" unless missing_css.empty?
      end
      errors
    end

    def css_difference(selector1, selector2)
      difference = {}
      selector2_representation = selector2.rule_based_representation
      selector1.representation.each do |path, selector1_css|
        if selector2_css = selector2_representation[path]
          difference[path] = Hash[selector2_css.to_a - selector1_css.to_a]
        end
      end
      difference
    end
  end
end
