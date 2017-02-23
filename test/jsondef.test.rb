require 'test/unit'
require 'json'
require_relative '../lib/jsondef.rb'

class TestJsondef < Test::Unit::TestCase

  def test_object_strict_on
    rule = JsonRuleObject
      .new
      .set_strict
      .add_key_rule(JsonRuleObjectKey.new('foo'))
    {
      '{"foo": 1}' => true,
      '{"foo": "bar"}' => true,
      '{"foo": ""}' => true,
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

  def test_object_strict_off
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

  def test_object_optional_key
    rule = JsonRuleObject
      .new
      .add_key_rule(JsonRuleObjectKey.new('foo').set_optional)
    {
      '{"foo": 1}' => true,
      '{"foo": "bar"}' => true,
      '{"foo": ""}' => true,
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
    all_types = [:number, :string, :array, :object]
    {
      '{"foo": 123}' => :number,
      '{"foo": "bar"}' => :string,
      '{"foo": []}' => :array,
      '{"foo": [1, 2, 3]}' => :array,
      '{"foo": {}}' => :object,
      '{"foo": {"bar": 123}}' => :object,
    }.each do |raw, expected_type|
      j = JSON.parse(raw)
      rule = JsonRuleObject
        .new
        .add_key_rule(JsonRuleObjectKey.new('foo').set_value_type(expected_type))
      assert(JsonDef.verify(j, rule))

      all_types.each do |type|
        next if type == expected_type
        anti_rule = JsonRuleObject
          .new
          .add_key_rule(JsonRuleObjectKey.new('foo').set_value_type(type))
        assert(!JsonDef.verify(j, anti_rule))
      end
    end
  end

  def test_nested_rule
    j = JSON.parse('{"foo": {"bar": {"baz": 123}}}')
    {:number => true, :string => false, :object => false, :array => false}.each do |type, expected|
      rule = JsonRuleObject
        .new
        .set_strict
        .add_key_rule(JsonRuleObjectKey
          .new('foo')
          .set_value_rule(JsonRuleObject
            .new
            .add_key_rule(JsonRuleObjectKey
              .new('bar')
              .set_value_rule(JsonRuleObject
                .new
                .add_key_rule(JsonRuleObjectKey
                  .new('baz')
                  .set_value_type(type))))))
      assert_equal(expected, JsonDef.verify(j, rule))
    end
  end

end
