require 'test/unit'
require 'json'
require_relative '../lib/jsondef.rb'

class TestEnd2End < Test::Unit::TestCase

  def test_valid_sample
    {
      'valid.sample.json' => 'rule.sample.yml',
      'real_response_example.json' => 'real_response_rule_example.yml'
    }.each do |json_file, rule_file|
      j = JSON.parse(IO.read(__dir__ + '/../example/' + json_file))
      c = ConfigReaderFactory.fromYamlFile(__dir__ + '/../example/' + rule_file)
      assert(JsonDef.verify(j, c.rule))
    end
  end

end
