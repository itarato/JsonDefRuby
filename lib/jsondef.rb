module JsonDef

  def JsonDef.verify(obj, rule)
    case rule.class
    when JsonRuleObject
      JsonDef.verify_object(obj, rule)

    when JsonRuleArray
      JsonDef.verify_array(obj, rule)

    when JsonRuleString
      JsonDef.verify_string(obj, rule)

    else
      raise 'Unknown rule at [verify] level'
    end
  end

  def JsonDef.verify_string(obj, rule)
    return false unless obj.class == String
    true
  end

  def JsonDef.verify_number(obj, rule)
    return false unless obj.class == Numeric
    true
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

  attr_reader :key_rules, :keys, :allow_other_keys

  def initialize()
    @allow_other_keys = true
    @key_rules = []
    @keys = []
  end

  def disallow_other_keys
    @allow_other_keys = false
    self
  end

  def add_key_rule(rule)
    @key_rules.push(rule)
    @keys.push(rule.key)
    self
  end

end

class JsonRuleObjectKey

  ANY_TYPE = :wildcard

  attr_reader :required, :key, :value

  def initialize(key)
    @key = key
    @required = true
    @value = :wildcard
  end

  def set_optional
    @required = false
    self
  end

  def set_value_rule(rule)
    @value = rule
    self
  end

end

class JsonRuleArray
end

class JsonRuleNumber
end

class JsonRuleString
end
