module StyleCop
  module PublicMethods
    def has_child(selector)
      RegisterStyle.add_rule("> #{selector}")
    end

    def has_nested_children(*args)
      rule = ""
      args.each do |arg|
        rule = "#{rule}> #{arg} "
      end
      RegisterStyle.add_rule(rule.strip)
    end

    def register_style_structure_for(selector, &block)
      block ? RegisterStyle.new(selector, &block) : (raise(StandardError, "No block given."))
    end

    def assert_style_structure_for(selector)
      AssertStyle.new(selector, RegisterStyle.rules, self).has_correct_structure
    end
  end
end
