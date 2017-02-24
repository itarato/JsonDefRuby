require 'yaml'
require 'pp'
require_relative 'jsondef.rb'

module ConfigReaderFactory

  def ConfigReaderFactory.fromYamlFile(path)
    ConfigReader.new(YAML.load(IO.read(path)))
  end

end

class ConfigReader

  attr_reader :rule

  def initialize(conf)
    @rule = parse_element(conf['rule'])
  end

  def parse_element(conf)
    case conf['type']
    when 'object'
      parse_object(conf)
    when 'array'
      parse_array(conf)
    when 'string'
      parse_string(conf)
    when 'number'
      parse_number(conf)
    when 'boolean'
      parse_boolean(conf)
    when 'nullval'
      parse_null(conf)
    else
      raise "Unknown rule type: #{conf['type']}"
    end
  end

  def parse_object(conf)
    rule = JsonRuleObject.new
    conf['keys'].each { |k, v| rule.add_key_rule(parse_object_key(k, v)) } if conf.has_key?('keys')

    rule.disallow_other_keys if conf.has_key?('disallow_other_keys') && conf['disallow_other_keys']
    rule
  end

  def parse_object_key(key, conf)
    rule = JsonRuleObjectKey.new(key)
    rule.set_optional if conf.has_key?('optional') && conf['optional']
    rule.set_rule(parse_element(conf['rule'])) if conf.has_key?('rule')
    rule
  end

  def parse_array(conf)
    rule = JsonRuleArray.new
    min_val = if conf.has_key?('min') then conf['min'] else nil end
    max_val = if conf.has_key?('max') then conf['max'] else nil end
    rule.set_count(min_val, max_val)
    rule.set_rule(parse_element(conf['rule'])) if conf.has_key?('rule')
    rule
  end

  def parse_string(conf)
    rule = JsonRuleString.new(extract_exact_value(conf))
    rule
  end

  def parse_number(conf)
    rule = JsonRuleNumber.new(extract_exact_value(conf))
    rule
  end

  def parse_boolean(conf)
    rule = JsonRuleBoolean.new(extract_exact_value(conf))
    rule
  end

  def parse_null(conf)
    JsonRuleNull.new
  end

  def extract_exact_value(conf)
    if conf.has_key?('value')
      conf['value']
    else
      JsonDef::ANY_VALUE
    end
  end

end
