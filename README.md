# AppConfig

A simple Ruby gem that wraps ENV variable access behind clean method calls.

## Installation

Add to your Gemfile:

```ruby
gem "appconfig"
```

Or install directly:

```
gem install appconfig
```

## Use Cases

AppConfig supports two general approaches to configuration. You can use both together, but good hygiene is to choose your horse:

1. **ENV path** — Read configuration directly from environment variables. No setup required; just call `AppConfig.my_variable` and it reads `ENV["MY_VARIABLE"]`. Ideal when your deployment injects all configuration via the environment.

2. **YAML file path** — Load a YAML configuration file keyed by `RAILS_ENV`. Provides structured, nested configuration with dot-notation access. Ideal when you prefer a single config file per environment.

When both are in play, YAML values take precedence over ENV variables.

## Usage

### Basic string access

```ruby
# Equivalent to ENV["HOST"].to_s.strip
AppConfig.host
```

Returns an empty string when the variable is missing or empty.

### Boolean access

Append `?` to automatically convert the value to a boolean:

```ruby
# ENV["FEATURE_ENABLED"] = "true"
AppConfig.feature_enabled?  # => true

# ENV["FEATURE_ENABLED"] = "false"
AppConfig.feature_enabled?  # => false
```

Boolean conversion is case-insensitive and recognizes these values:

- **Truthy:** `true`, `on`, `yes`, `1`
- **Falsy:** `false`, `off`, `no`, `0`, empty string

Missing or empty variables return `false`.

### Default values

```ruby
AppConfig.host(:default => "http://localhost:3000")
```

### Type conversion

```ruby
AppConfig.port(:conversion => :to_i)  # => 3000
```

### Combined

```ruby
AppConfig.port(:default => "3000", :conversion => :to_i)
```

## YAML configuration file

AppConfig can optionally load a YAML file keyed by `RAILS_ENV`. YAML values take precedence over ENV variables.

### Setup via initializer

```ruby
# config/initializers/app_config.rb
AppConfig.configure do |config|
  config.config_file = Rails.root.join("config", "app_config.yml")
end
```

### Example YAML

```yaml
development:
  aws_secret: "dev-secret"
  database:
    host: "localhost"
    port: 5432

production:
  aws_secret: "prod-secret"
  database:
    host: "prod-db.example.com"
    port: 5432
```

### Accessing YAML values

```ruby
AppConfig.aws_secret       # => "dev-secret"
AppConfig.database.host    # => "localhost"
AppConfig.database.port    # => 5432
```

Nested structures are deeply converted to OpenStruct for dot-notation access. When a key exists in both YAML and ENV, the YAML value wins.

## Core extensions

This gem adds a `to_bool` method to `String`, `TrueClass`, `FalseClass`, and `NilClass` for boolean conversion support.

## License

MIT
