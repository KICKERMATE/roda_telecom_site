# frozen_string_literal: true

require 'dry-types'

# StrippedString Module
module SchemaTypes
  include Dry.Types

  StrippedString = self::String.constructor(&:strip)
end
