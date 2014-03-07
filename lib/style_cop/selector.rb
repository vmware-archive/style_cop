module StyleCop
  class Selector
    def initialize(selector)
      @selector = selector
    end

    def computed_style
      Hash[css.split(/\s*;\s*/).map { |s| s.split(/\s*:\s*/) }]
    end

    private

    attr_reader :selector

    def css
      session.evaluate_script(computed_style_script)["cssText"]
    end

    def session
      selector.session
    end

    def computed_style_script
      %{
        var node = document.evaluate('/#{selector.path}',
            document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null ).singleNodeValue
        window.getComputedStyle(node);
      }
    end
  end
end
