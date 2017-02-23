
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

  # @todo rename it to optional! - might be more ruby-ist
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

  def initialize
  end

end

class JsonRuleSingleValue < JsonRuleBase

  def initialize
  end

end

class JsonRuleNumber < JsonRuleSingleValue

  def initialize
  end

end

class JsonRuleString < JsonRuleSingleValue

  def initialize
  end

end

class JsonRuleNull < JsonRuleSingleValue

  def initialize
  end

end

class JsonRuleBoolean < JsonRuleSingleValue

  def initialize
  end

end
