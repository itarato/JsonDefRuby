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
      assert(JsonDef.verify(j, rule), "JSON #{j} has value of #{expected_type}")

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

  def test_initial_array
    rule = JsonRuleArray.new
    [
      '[]',
      '[1, 3]',
      '[{}, {"foo": "bar"}]',
    ].each do |raw_json|
      j = JSON.parse(raw_json)
      assert(JsonDef.verify(j, rule), "#{raw_json} is an array")
    end
  end

  def test_any_value
    rule = JsonRuleObject
      .new
      .add_key_rule(JsonRuleObjectKey.new('foo'))
    [
      '{"foo": null}',
      '{"foo": 123}',
      '{"foo": "bar"}',
      '{"foo": {}}',
      '{"foo": []}',
    ].map { |s| JSON.parse(s) }.each { |o| assert(JsonDef.verify(o, rule), "Object #{o.inspect} verifies #{rule.inspect}.") }
  end

  def test_exact_value
    rule = JsonRuleObject
      .new
      .add_key_rule(JsonRuleObjectKey.new('foo'))
    {
      '{"foo": 123}' => JsonRuleNumber.new(123),
      '{"foo": 12.3}' => JsonRuleNumber.new(12.3),
      '{"foo": true}' => JsonRuleBoolean.new(true),
      '{"foo": false}' => JsonRuleBoolean.new(false),
      '{"foo": "123"}' => JsonRuleString.new("123"),
      '{"foo": "bar"}' => JsonRuleString.new('bar'),
    }.each do |raw_json, expected|
      j = JSON.parse(raw_json)
      rule = JsonRuleObject
        .new
        .add_key_rule(JsonRuleObjectKey
          .new('foo')
          .set_rule(expected))
      assert(JsonDef.verify(j, rule), "#{raw_json} value is #{expected.inspect}")
    end
  end

  def test_array_boundaries
    j = JSON.parse('[1, 2, 3]')
    [
      [nil, nil, true],

      [0, nil, true],
      [1, nil, true],
      [3, nil, true],
      [4, nil, false],

      [nil, 0, false],
      [nil, 1, false],
      [nil, 2, false],
      [nil, 3, true],
      [nil, 10, true],

      [0, 3, true],
      [0, 10, true],
      [2, 3, true],
      [3, 3, true],
      [6, 7, false],
      [1, 2, false],
    ].each do |cases|
      rule = JsonRuleArray.new.set_count(cases[0], cases[1])
      assert_equal(cases[2], JsonDef.verify(j, rule), "#{j.inspect} is #{cases[2]} for range #{cases[0]}-#{cases[1]}")
    end
  end

  def test_array_unified_rule_match
    good_arr = '[
      {"id": 1},
      {"id": 2},
      {"id": 3}
    ]'
    j = JSON.parse(good_arr)
    good_rule = JsonRuleArray
      .new
      .set_rule(JsonRuleObject
        .new
        .add_key_rule(JsonRuleObjectKey
          .new('id')
          .set_rule(JsonRuleNumber.new)))

    assert(JsonDef.verify(j, good_rule))
  end

  def test_array_unified_rule_not_match
    good_arr = '[
      {"id": 1},
      {"id": 2},
      {"id": "not-number"}
    ]'
    j = JSON.parse(good_arr)
    good_rule = JsonRuleArray
      .new
      .set_rule(JsonRuleObject
        .new
        .add_key_rule(JsonRuleObjectKey
          .new('id')
          .set_rule(JsonRuleNumber.new)))

    assert_equal(false, JsonDef.verify(j, good_rule))
  end

end
