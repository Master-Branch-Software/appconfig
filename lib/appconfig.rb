# frozen_string_literal: true

require "ostruct"
require "yaml"
require_relative "appconfig/version"
require_relative "appconfig/to_bool"

#################################################################################
# AppConfig
#
# A wrapper singletonish class to wrap and make nicer dealing with ENV variables.
#
# To use:  AppConfig.my_variable
#
# Example: AppConfig.host
# Is equivalent to ENV["HOST"]
#
# In the simplest case a string with the value, or an empty string if missing,
# will be returned.
#
# If a boolean value is expected, like MY_VARIABLE=false you can append a `?`
# to the call and have the conversion done automatically:
#
# Example: AppConfig.my_variable?
#
# Will convert MY_VARIABLE=false to a boolean as it's returned.
#
# OPTIONS:
#   default
#
#   A default value can be supplied. If an ENV variable is missing or empty
#   the default will be returned:
#   Example: AppConfig.host(:default => "http://localhost:3000")
#
#   conversion
#
#   A conversion can be supplied for the value:
#   Example: AppConfig.port(:conversion => :to_i)
#     --> returns 3000 v "3000"
#   NOTE: Normal conversion rules apply and no special exception handling is
#   offered internally.
#
# YAML CONFIG:
#   AppConfig can optionally load a YAML configuration file keyed by RAILS_ENV.
#   YAML values take precedence over ENV variables.
#   Nested YAML structures are converted to OpenStruct for dot-notation access.
#
#   Example initializer (config/initializers/app_config.rb):
#     AppConfig.configure do |config|
#       config.config_file = Rails.root.join("config", "app_config.yml")
#     end
#
#   Example YAML:
#     development:
#       aws_secret: "dev-secret"
#       database:
#         host: "localhost"
#
#   AppConfig.aws_secret       # => "dev-secret"
#   AppConfig.database.host    # => "localhost"

class AppConfig
  class Configuration
    attr_accessor :config_file
  end

  @config = nil
  @configuration = nil

  def self.configure
    @configuration = Configuration.new

    yield(@configuration)
    load_config
  end

  def self.config
    @config
  end

  def self.reset!
    @config = nil
    @configuration = nil
  end

  def self.method_missing(method_name, *args)
    options = args.first

    # Accept `myvariable?` calls for boolean valued ENV variables and
    # do the conversion automatically
    if method_name.to_s.end_with?('?')
      env_variable = method_name.to_s[0..-2]
      boolean_conversion = true
    else
      env_variable = method_name.to_s
      boolean_conversion = false
    end

    # YAML config takes precedence over ENV
    if @config && @config.respond_to?(env_variable)
      value = @config.send(env_variable)

      if boolean_conversion
        return value.to_bool
      end

      return value
    end

    # Fall back to ENV
    result = ENV[env_variable.upcase].to_s.strip

    if boolean_conversion
      if options && result.empty?
        result = options[:default]
      end

      result.to_bool
    elsif options
      if result.empty?
        result = options[:default]
      end

      options[:conversion] ? result.send(options[:conversion]) : result
    else
      result
    end
  end

  def self.respond_to_missing?(_method_name, _include_private = false)
    true
  end

  def self.load_config
    return unless @configuration&.config_file

    path = @configuration.config_file.to_s
    env = ENV.fetch("RAILS_ENV", "development")
    yaml = YAML.safe_load(File.read(path))
    env_config = yaml[env] || {}

    @config = deep_ostruct(env_config)
  end

  def self.deep_ostruct(hash)
    OpenStruct.new(hash.transform_values { |value|
      case value
      when Hash
        deep_ostruct(value)
      when Array
        value.map { |item| item.is_a?(Hash) ? deep_ostruct(item) : item }
      else
        value
      end
    })
  end

  private_class_method :load_config, :deep_ostruct
end
