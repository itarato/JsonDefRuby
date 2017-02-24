
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

  attr_reader :required, :key, :rule

  def initialize(key)
    @key = key
    @required = true
    @rule = JsonDef::ANY_TYPE
  end

  # @todo rename it to optional! - might be more ruby-ist
  def set_optional
    @required = false
    self
  end

  def set_rule(rule)
    @rule = rule
    self
  end

end

class JsonRuleArray < JsonRuleBase

  attr_reader :min_count, :max_count, :unified_rule

  def initialize
    @min_count = 0
    @max_count = -1
    @unified_rule = nil
  end

  def set_rule(rule)
    @unified_rule = rule
    self
  end

  def set_count(min = nil, max = nil)
    @min_count = min unless min == nil
    @max_count = max unless max == nil
    self
  end

end

class JsonRuleSingleValue < JsonRuleBase

  attr_reader :value

  def initialize(value = JsonDef::ANY_VALUE)
    @value = value
  end

end

class JsonRuleNumber < JsonRuleSingleValue
end

class JsonRuleString < JsonRuleSingleValue
end

class JsonRuleBoolean < JsonRuleSingleValue
end

class JsonRuleNull < JsonRuleSingleValue

  def initialize
    super(nil)
  end

end
