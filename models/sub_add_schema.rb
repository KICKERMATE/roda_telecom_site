# frozen_string_literal: true

require 'dry-schema'

require_relative 'schema_types'

SubAddSchema = Dry::Schema.Params do
  required(:first_name).filled(SchemaTypes::StrippedString)
  required(:last_name).filled(SchemaTypes::StrippedString)
  required(:calling_plan).filled(SchemaTypes::StrippedString)
end
