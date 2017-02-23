
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
