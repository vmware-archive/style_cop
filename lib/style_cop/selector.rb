module StyleCop
  class Selector

    def initialize(selector)
      @selector = selector
    end

    def key
      if selector['class'] && selector['class'] != 'style-cop-pattern'
        ".#{selector['class'].gsub(' ', '.')}".gsub(".style-cop-pattern", "")
      elsif selector['id']
        "##{selector['id']}"
      else
        selector.tag_name
      end
    end

    def full_style_representation
      representation(FullStylesHash)
    end

    def relevant_style_representation
      representation(RelevantStylesHash)
    end

    def representation(style_hash_class)
      return { key => style_hash_class.new(session, key, selector.path) } if children.empty?

      children_hash = children.map do |child|
        child.representation(style_hash_class)
      end.inject({}) { |hash, h| hash.merge!(h) }

      Hash[children_hash.map { |child_key, value| ["#{key} #{child_key}", value] }].merge(
        key => style_hash_class.new(session, key, selector.path)
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

    class FullStylesHash < Hash

      def initialize(session, key, path)
        @session = session
        @key = key
        @path = path
        build_hash
      end

      private

      def build_hash
        attribute_value_pairs = computed_css.split(/\s*;\s*/).map { |s| s.split(/\s*:\s*/, 2) }
        attribute_value_pairs.each do |attribute, value|
          self[attribute] = value
        end
      end

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

    class RelevantStylesHash < FullStylesHash

      private

      def build_hash
        super
        self.select! do |key, value|
          relevant_attributes.include? key
        end
      end

      def relevant_attributes
        return @relevant_attributes if @relevant_attributes

        @relevant_attributes = []
        applicable_style = @session.evaluate_script(applicable_style_script)

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
          var node = document.evaluate("/#{@path}",
              document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null ).singleNodeValue
          window.getMatchedCSSRules(node);
        }
      end
    end
  end
end
