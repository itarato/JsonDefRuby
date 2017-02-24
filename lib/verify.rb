require_relative 'rules.rb'

module JsonDef

  ANY_TYPE = :wildcard
  ANY_VALUE = :any_value

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
    when 'JsonRuleBoolean'
      JsonDef.verify_bool(obj, rule)
    when 'JsonRuleNull'
      JsonDef.verify_null(obj, rule)
    else
      raise "Unknown rule at [verify] level: #{rule.class}"
    end
  end

  def JsonDef.verify_single_value(obj, rule)
    rule.value == JsonDef::ANY_VALUE || rule.value == obj
  end

  def JsonDef.verify_string(obj, rule)
    return false unless obj.kind_of?(String)
    return false unless JsonDef.verify_single_value(obj, rule)
    true
  end

  def JsonDef.verify_number(obj, rule)
    return false unless obj.kind_of?(Numeric)
    return false unless JsonDef.verify_single_value(obj, rule)
    true
  end

  def JsonDef.verify_bool(obj, rule)
    return false unless obj == true || obj == false
    return false unless JsonDef.verify_single_value(obj, rule)
    true
  end

  def JsonDef.verify_null(obj, rule)
    return false unless JsonDef.verify_single_value(obj, rule)
    true
  end

  def JsonDef.verify_object(obj, rule)
    return false unless obj.kind_of?(Hash)

    rule.key_rules.each do |key_rule|
      return false if key_rule.required && !obj.has_key?(key_rule.key)
      return true unless obj.has_key?(key_rule.key)

      case
      when key_rule.rule == JsonDef::ANY_TYPE
        next
      when key_rule.rule.kind_of?(JsonRuleBase)
        return false unless JsonDef.verify(obj[key_rule.key], key_rule.rule)
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
    return false unless rule.min_count < 0 || obj.count >= rule.min_count
    return false unless rule.max_count < 0 || obj.count <= rule.max_count

    if rule.unified_rule
      return false unless obj.all? { |e| JsonDef.verify(e, rule.unified_rule) }
    end

    true
  end

end
