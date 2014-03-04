module StyleCop
  class RegisterStyle
    @@rules = []

    def initialize(selector, &block)
      yield
    end

    def self.rules
      @@rules
    end

    def self.add_rule(rule)
      @@rules << rule
    end
  end
end
