module StyleCop
  class AssertStyle
    def initialize(selector, rules, test_context)
      @selector = selector
      @rules = rules
      @test_context = test_context
    end

    def has_correct_structure
      selector_present ? fulfills_all_rules : raise_error
    end

    private

    attr_reader :selector, :test_context, :rules

    def selector_present
      test_context.has_css?(selector)
    end

    def raise_error
      raise StandardError, "Selector: #{selector} is not present."
    end

    def fulfills_all_rules
      test_context.page.all(selector).each do |element|
        has(element)
      end
    end

    def has(element)
      rules.each do |node|
        test_context.expect(element).to test_context.have_selector(node)
      end
    end
  end
end
