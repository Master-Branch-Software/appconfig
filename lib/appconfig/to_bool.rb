# frozen_string_literal: true

#################################################################################
# Adds to_bool conversion to String, TrueClass, FalseClass, and NilClass so
# that boolean-valued ENV strings can be converted cleanly.

class String
  TRUTHY_VALUES = /\A(true|on|yes|1)\z/i
  FALSY_VALUES = /\A(false|off|no|0)\z/i

  def to_bool
    if match?(TRUTHY_VALUES)
      return true
    elsif match?(FALSY_VALUES) || strip.empty?
      return false
    end

    raise "No conversion of '#{self}' to boolean."
  end
end

class FalseClass
  def to_bool
    self
  end
end

class TrueClass
  def to_bool
    self
  end
end

class NilClass
  def to_bool
    false
  end
end
