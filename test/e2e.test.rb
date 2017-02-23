require 'test/unit'
require 'json'
require_relative '../lib/config_reader.rb'
require_relative '../lib/jsondef.rb'

class TestEnd2End < Test::Unit::TestCase

  def test_valid_sample
    j = JSON.parse(IO.read(__dir__ + '/../example/valid.sample.json'))
    c = ConfigReaderFactory.fromJsonFile(__dir__ + '/../example/rule.sample.yml')
    assert(JsonDef.verify(j, c.rule))
  end

end
