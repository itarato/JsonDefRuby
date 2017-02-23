JSON Definition Library (for Ruby 2.x)
======================================

This is a learning project to get into Ruby and Gems.

In heavy development.

# Requirements

- Ruby >=2.x


# Install

You can follow the gem addition on https://rubygems.org/gems/jsondef or just:

```bash
gem install jsondef
```

And in code:

```ruby
require 'jsondef'
```


# Usage

Let's say you have an API returning a JSON response like this:

```json
{
  "status": "ok",
  "result": {
    "count": 2,
    "items": ["Steve", "Gibson"]
  }
}
```

You can write a rule file to validate this kind of JSON and keep it in your project folder:

```yaml
rule:
  type: object
  disallow_other_keys: true
  keys:
    status:
      rule:
        type: string
    result:
      optional: true
      rule:
        type: object
        disallow_other_keys: true
        keys:
          count:
            rule:
              type: number
          items:
            optional: true
            rule:
              type: array
```

During your application workflow you can verify the response with the rule like this:

```ruby
# Load the library
require 'jsondef'

# Gather the REST response and convert raw JSON string to Ruby object
response_object = JSON.parse(my_rest_json_response)
# Initialize the descriptor from the YAML file
json_config = ConfigReaderFactory.fromYamlFile('path/to/rule/file.yml')

# Verify
assert(JsonDef.verify(response_object, json_config.rule))
```
