# frozen_string_literal: true

require 'dry-schema'

require_relative 'schema_types'

SubFilterSchema = Dry::Schema.Params do
  optional(:phone_number).maybe(:integer, gteq?: 100_000, lteq?: 999_999)
  optional(:last_name).maybe(SchemaTypes::StrippedString)
end
