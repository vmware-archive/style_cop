module StyleCop
  class Selector
    EXCLUDED_KEYS = [
      "width", "height", "top", "bottom", "right", "left",
      "-webkit-perspective-origin", "-webkit-transform-origin",
      "border-bottom-color", "border-left-color", "border-right-color", "border-top-color",
      "outline-color", "-webkit-column-rule-color", "-webkit-text-emphasis-color", "-webkit-text-fill-color", "-webkit-text-stroke-color"
    ]

    def initialize(selector)
      @selector = selector
    end

    def key
      if selector['class']
        ".#{selector['class'].gsub(' ', '.')}"
      elsif selector['id']
        "##{selector['id']}"
      else
        selector.tag_name
      end
    end

    def representation
      clean_key = key.gsub(".style-cop-pattern", "")
      return { clean_key => computed_style } if children.empty?
      children_hash = children.map(&:representation).inject({}) { |hash, h| hash.merge!(h) }
      Hash[children_hash.map { |key, value| ["#{clean_key} #{key}", value] }].merge(
        clean_key => computed_style
      )
    end

    def rule_based_representation
      clean_key = key.gsub(".style-cop-pattern", "")
      return { clean_key => applicable_css } if children.empty?
      children_hash = children.map(&:representation).inject({}) { |hash, h| hash.merge!(h) }
      Hash[children_hash.map { |key, value| ["#{clean_key} #{key}", value] }].merge(
        clean_key => applicable_css
      )
    end

    private

    attr_reader :selector

    def computed_style
      computed_style_hash.tap do |hash|
        EXCLUDED_KEYS.each { |key| hash.delete(key) }
      end
    end

    def children
      selector.all(:xpath, "#{selector.path}/*").map do |child|
        Selector.new(child)
      end
    end

    def computed_style_hash
      Hash[computed_css.split(/\s*;\s*/).map { |s| s.split(/\s*:\s*/) }]
    end

    def computed_css
      if computed_style = session.evaluate_script(computed_style_script)
        computed_style["cssText"]
      else
        raise RuntimeError.new("Can't find css for #{selector.key}")
      end
    end

    def session
      selector.session
    end

    def computed_style_script
      %{
        var node = document.evaluate("/#{selector.path}",
            document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null ).singleNodeValue
        window.getComputedStyle(node);
      }
    end

    def applicable_css
      relevant_attributes = []
      applicable_style = session.evaluate_script(applicable_style_script) 

      if applicable_style && !applicable_style.empty?
        (0...applicable_style['length']).each do |i|
          rule = applicable_style[i.to_s]['style']
          (0...rule['length']).each do |j|
            relevant_attributes << rule[j.to_s]
          end
        end
      else
        return {}
      end
      relevant_attributes.uniq!

      computed_style_hash.select { |key, value| relevant_attributes.include? key }
    end

    def applicable_style_script
      %{
        var node = document.evaluate("/#{selector.path}",
            document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null ).singleNodeValue
        window.getMatchedCSSRules(node);
      }
    end
  end
end
