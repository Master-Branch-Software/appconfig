# frozen_string_literal: true

#################################################################################
# Adds to_bool conversion to String, TrueClass, FalseClass, and NilClass so
# that boolean-valued ENV strings can be converted cleanly.

class String
  def to_bool
    if match?(/\Atrue\z/i)
      return true
    elsif match?(/\Afalse\z/i) || strip.empty?
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
