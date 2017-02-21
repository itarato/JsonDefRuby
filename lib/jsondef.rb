module JsonDef

  def JsonDef.verify(obj, rule)
    case rule.class.to_s
    when 'JsonRuleObject'
      JsonDef.verify_object(obj, rule)
    else
      raise 'Unknown rule at [verify] level'
    end
  end

  def JsonDef.verify_value_type(value, type)
    case type
    when :object
      value.kind_of?(Hash)
    when :number
      value.kind_of?(Numeric)
    when :string
      value.kind_of?(String)
    when :array
      value.kind_of?(Array)
    when :wildcard
      # Land of satisfaction.
      true
    else
      raise 'Unknown value type declaration'
    end
  end

  def JsonDef.verify_object(obj, rule)
    return false unless obj.kind_of?(Hash)

    rule.key_rules.each do |key_rule|
      return false if key_rule.required && !obj.has_key?(key_rule.key)
      return true unless obj.has_key?(key_rule.key)

      case
      when key_rule.value.kind_of?(Symbol)
        return false unless JsonDef.verify_value_type(obj[key_rule.key], key_rule.value)

      when key_rule.value.kind_of?(JsonRuleObject)
        return false unless JsonDef.verify_object(obj[key_rule.key], key_rule.value)

      when key_rule.value.kind_of?(JsonRuleArray)
        return false unless JsonDef.verify_array(obj[key_rule.key], key_rule.value)

      else
        # Expected an exact value given.
        return false unless obj[key_rule.key] == key_rule.value
      end
    end

    # @todo In case of strict, check if there are other not-allowed keys.
    if rule.strict?
      obj.each { |k, v| return false unless rule.keys.member?(k) }
    end

    true
  end

  def JsonDef.verify_array(obj, rule)
    return false if obj.kind_of?(Array)
    true
  end

end

class JsonRuleObject

  attr_reader :key_rules, :keys

  def initialize()
    @strict = false
    @key_rules = []
    @keys = []
  end

  def strict?
    @strict
  end

  def set_strict
    @strict = true
    self
  end

  def add_key_rule(rule)
    @key_rules.push(rule)
    @keys.push(rule.key)
    self
  end

end

class JsonRuleArray

  def initialize
  end

end

class JsonRuleObjectKey

  attr_reader :required, :key, :value

  def initialize(key)
    @key = key
    @required = true
    @value = :wildcard
  end

  def set_optional()
    @required = false
    self
  end

  def set_value_type(type)
    @value = type
    self
  end

  def set_value_rule(rule)
    @value = rule
    self
  end

end
