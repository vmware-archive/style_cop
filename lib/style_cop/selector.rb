module StyleCop
  class Selector

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
      return { clean_key => ComputedStylesHash.new(session, key, selector.path) } if children.empty?
      children_hash = children.map(&:representation).inject({}) { |hash, h| hash.merge!(h) }
      Hash[children_hash.map { |key, value| ["#{clean_key} #{key}", value] }].merge(
        clean_key => ComputedStylesHash.new(session, key, selector.path)
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

    def children
      selector.all(:xpath, "#{selector.path}/*").map do |child|
        Selector.new(child)
      end
    end

    def session
      selector.session
    end


    def applicable_css
      ComputedStylesHash.new(session, key, selector.path).select do |key, value|
        relevant_attributes.include? key
      end
    end

    def relevant_attributes
      return @relevant_attributes if @relevant_attributes

      @relevant_attributes = []
      applicable_style = session.evaluate_script(applicable_style_script) 

      if applicable_style && !applicable_style.empty?
        (0...applicable_style['length']).each do |i|
          rule = applicable_style[i.to_s]['style']
          (0...rule['length']).each do |j|
            @relevant_attributes << rule[j.to_s]
          end
        end
      else
        return []
      end
      @relevant_attributes = @relevant_attributes.uniq
    end

    def applicable_style_script
      %{
        var node = document.evaluate("/#{selector.path}",
            document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null ).singleNodeValue
        window.getMatchedCSSRules(node);
      }
    end

    class ComputedStylesHash < Hash

      def initialize(session, key, path)
        @session = session
        @key = key
        @path = path

        attribute_value_pairs = computed_css.split(/\s*;\s*/).map { |s| s.split(/\s*:\s*/) }
        attribute_value_pairs.each do |attribute, value|
          self[attribute] = value
        end
      end

      private

      def computed_css
        if computed_style = @session.evaluate_script(computed_style_script)
          computed_style["cssText"]
        else
          raise RuntimeError.new("Can't find css for #{@key}")
        end
      end

      def computed_style_script
        %{
        var node = document.evaluate("/#{@path}",
            document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null ).singleNodeValue
        window.getComputedStyle(node);
        }
      end
    end
  end
end
