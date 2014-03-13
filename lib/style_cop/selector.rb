module StyleCop
  class Selector
    EXCLUDED_KEYS = [
      "width", "height", "top", "bottom", "right", "left",
      "-webkit-perspective-origin", "-webkit-transform-origin"
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

    private

    attr_reader :selector

    def computed_style
      style_hash.tap do |hash|
        EXCLUDED_KEYS.each { |key| hash.delete(key) }
      end
    end

    def children
      selector.all(:xpath, "#{selector.path}/*").map do |child|
        Selector.new(child)
      end
    end

    def style_hash
      Hash[css.split(/\s*;\s*/).map { |s| s.split(/\s*:\s*/) }]
    end

    def css
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
  end
end
