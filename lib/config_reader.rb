require 'yaml'
require 'jsondef'
require 'pp'

module ConfigReaderFactory

  def ConfigReaderFactory.fromJsonFile(path)
    ConfigReader.new(YAML.load(IO.read(path)))
  end

end

class ConfigReader

  attr_reader :rule

  def initialize(conf)
    pp conf
    @rule = parse_element(conf)
  end

  def parse_element(conf)
    raise "Missing"
  end

end

c = ConfigReaderFactory.fromJsonFile(__dir__ + '/../example/rule.sample.yml')
