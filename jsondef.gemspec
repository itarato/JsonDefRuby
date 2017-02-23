Gem::Specification.new do |s|
  s.name        = 'jsondef'
  s.version     = '0.1.1'
  s.date        = '2017-02-23'
  s.summary     = "JSON definition and verification lib."
  s.description = "Can create JSON descriptor and verify if a given object satisfy it."
  s.authors     = ["Peter Arato"]
  s.email       = 'it.arato@gmail.com'
  s.files       = [
    "lib/jsondef.rb",
    "lib/rules.rb",
    "lib/verify.rb",
    "lib/config_reader.rb"]
  s.required_ruby_version = '>= 2.0.0'
  s.homepage    = 'https://github.com/itarato/JsonDefRuby'
  s.license     = 'MIT'
end
