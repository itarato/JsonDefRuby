require_relative '../lib/jsondef'
require 'test/unit'
require 'json'

class TestJsondef < Test::Unit::TestCase

  def test_strict_on
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

  def test_strict_off
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

end

=begin

obj_rule = JsonRuleObject.new
  .set_strict
  .add_key_rule(JsonRuleObjectKey.new('foo').set_value_type(:string))

[
  '{"foo": "bar"}',
  '{"foo": "bar", "baz": 12}',
  '["foo", "bar"]',
  '{}',
  '{"bar": "foo"}',
  '{"foo": 12}'
].each do |raw|
  json_obj = JSON.parse(raw);
  p json_obj, JsonDef.verify(json_obj, obj_rule)
end

=end
