module JsonDef

  ANY_TYPE = :wildcard

  def JsonDef.verify(obj, rule)
    case rule.class.to_s
    when 'JsonRuleObject'
      JsonDef.verify_object(obj, rule)
    when 'JsonRuleArray'
      JsonDef.verify_array(obj, rule)
    when 'JsonRuleString'
      JsonDef.verify_string(obj, rule)
    when 'JsonRuleNumber'
      JsonDef.verify_number(obj, rule)
    else
      raise "Unknown rule at [verify] level: #{rule.class}"
    end
  end

  def JsonDef.verify_string(obj, rule)
    return false unless obj.kind_of?(String)
    true
  end

  def JsonDef.verify_number(obj, rule)
    return false unless obj.kind_of?(Numeric)
    true
  end

  def JsonDef.verify_object(obj, rule)
    return false unless obj.kind_of?(Hash)

    rule.key_rules.each do |key_rule|
      return false if key_rule.required && !obj.has_key?(key_rule.key)
      return true unless obj.has_key?(key_rule.key)

      case
      when key_rule.value == JsonDef::ANY_TYPE
        next
      when key_rule.value.kind_of?(JsonRuleBase)
        return false unless JsonDef.verify(obj[key_rule.key], key_rule.value)
      else
        return false
      end
    end

    # @todo In case of not allowing other keys, check if there are other not-allowed keys.
    if !rule.allow_other_keys
      obj.each { |k, v| return false unless rule.keys.member?(k) }
    end

    true
  end

  def JsonDef.verify_array(obj, rule)
    return false unless obj.kind_of?(Array)
    true
  end

end

class JsonRuleBase
end

class JsonRuleObject < JsonRuleBase

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

  attr_reader :required, :key, :value

  def initialize(key)
    @key = key
    @required = true
    @value = JsonDef::ANY_TYPE
  end

  def set_optional
    @required = false
    self
  end

  def set_rule(rule)
    @value = rule
    self
  end

end

class JsonRuleArray < JsonRuleBase
end

class JsonRuleNumber < JsonRuleBase
end

class JsonRuleString < JsonRuleBase
end
