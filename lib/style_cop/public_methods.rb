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

    ### Need to be refactored into objects ###
    def register_style_structure_for(url, text_context)
      text_context.visit url

      base = text_context.page.all('.style-cop-pattern').first.native.attributes['class'].value.gsub(' style-cop-pattern', '')
      dom = text_context.page.find(".#{base}").native
      structure = build_structure(dom, base, {})
      rules = build_rules(structure, base, '', []).map{|r| r.gsub(" > .#{base} > ",'')}

      has_nested_children rules
    end

    def build_rules(structure, level, rule_base, rules)
      if structure["#{level}"].is_a?(Hash)
        rule_base = "#{rule_base} > .#{level}"
        structure["#{level}"].keys.each do |key|
          build_rules(structure["#{level}"], key, rule_base, rules)
        end
      else
        rules << "#{rule_base} > .#{level}"
      end
      rules
    end

    def build_structure(dom, base, structure) 
      children = dom.children.reject{|c| c.name != 'div'}

      if children.count != 0
        structure["#{base}"] = {}
        children.each do |child|
          build_structure(child, child.attributes['class'].value, structure["#{base}"])
        end
      else
        key = "#{base}".gsub(' ','.')
        structure[key] = dom.name
      end
      structure
    end
  end
end
