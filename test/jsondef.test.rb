require 'test/unit'
require 'json'
require_relative '../lib/jsondef.rb'

class TestJsondef < Test::Unit::TestCase

  def test_object_disallow_other_keys
    rule = JsonRuleObject
      .new
      .disallow_other_keys
      .add_key_rule(JsonRuleObjectKey.new('foo'))
    {
      '{"foo": 1}' => true,
      '{"foo": "bar"}' => true,
      '{"foo": null}' => true,
      '{"foo": false}' => true,
      '{"foo": true}' => true,
      '{"foo": [1, 2, 3]}' => true,
      '{"foo": {"bar": 1}}' => true,
      '{"foo": 0, "bar": 1}' => false,
      '{"baz": 0, "bar": 1}' => false,
      '{}' => false,
    }.each do |raw, expected|
      j = JSON.parse(raw)
      assert_equal(expected, JsonDef.verify(j, rule), "Verify #{raw} is #{expected}")
    end
  end

  def test_object_allow_other_keys
    rule = JsonRuleObject
      .new
      .add_key_rule(JsonRuleObjectKey.new('foo'))
    {
      '{"foo": 1}' => true,
      '{"foo": "bar"}' => true,
      '{"foo": ""}' => true,
      '{"foo": [1, 2, 3]}' => true,
      '{"foo": {"bar": 1}}' => true,
      '{"foo": 0, "bar": 1}' => true,
      '{"baz": 0, "bar": 1}' => false,
      '{}' => false,
    }.each do |raw, expected|
      j = JSON.parse(raw)
      assert_equal(expected, JsonDef.verify(j, rule), "Verify #{raw} is #{expected}")
    end
  end

  def test_object_key_is_optional
    rule = JsonRuleObject
      .new
      .add_key_rule(JsonRuleObjectKey.new('foo').set_optional)
    {
      '{"foo": 1}' => true,
      '{"foo": "bar"}' => true,
      '{"foo": null}' => true,
      '{"foo": [1, 2, 3]}' => true,
      '{"foo": {"bar": 1}}' => true,
      '{"foo": 0, "bar": 1}' => true,
      '{"baz": 0, "bar": 1}' => true,
      '{}' => true,
    }.each do |raw, expected|
      j = JSON.parse(raw)
      assert_equal(expected, JsonDef.verify(j, rule), "Verify #{raw} is #{expected}")
    end
  end

  def test_object_key_value_type
    all_types = [JsonRuleObject, JsonRuleArray, JsonRuleNumber, JsonRuleString, JsonRuleBoolean, JsonRuleNull]
    {
      '{"foo": 123}' => JsonRuleNumber,
      '{"foo": "bar"}' => JsonRuleString,
      '{"foo": []}' => JsonRuleArray,
      '{"foo": [1, 2, 3]}' => JsonRuleArray,
      '{"foo": {}}' => JsonRuleObject,
      '{"foo": {"bar": 123}}' => JsonRuleObject,
      '{"foo": null}' => JsonRuleNull,
      '{"foo": true}' => JsonRuleBoolean,
      '{"foo": false}' => JsonRuleBoolean,
    }.each do |raw, expected_type|
      j = JSON.parse(raw)
      rule = JsonRuleObject
        .new
        .add_key_rule(JsonRuleObjectKey.new('foo').set_rule(expected_type.new))
      assert(JsonDef.verify(j, rule))

      all_types.each do |type|
        next if type == expected_type
        anti_rule = JsonRuleObject
          .new
          .add_key_rule(JsonRuleObjectKey.new('foo').set_rule(type.new))
        assert(!JsonDef.verify(j, anti_rule), "Expect #{j} to fail for #{type}")
      end
    end
  end

  def test_nested_rule
    j = JSON.parse('{"foo": {"bar": {"baz": 123}}}')
    {
      JsonRuleNumber => true,
      JsonRuleString => false,
      JsonRuleObject => false,
      JsonRuleArray => false,
      JsonRuleBoolean => false,
      JsonRuleNull => false,
    }.each do |type, expected|
      rule = JsonRuleObject
        .new
        .disallow_other_keys
        .add_key_rule(JsonRuleObjectKey
          .new('foo')
          .set_rule(JsonRuleObject
            .new
            .add_key_rule(JsonRuleObjectKey
              .new('bar')
              .set_rule(JsonRuleObject
                .new
                .add_key_rule(JsonRuleObjectKey
                  .new('baz')
                  .set_rule(type.new))))))
      assert_equal(expected, JsonDef.verify(j, rule))
    end
  end

end
