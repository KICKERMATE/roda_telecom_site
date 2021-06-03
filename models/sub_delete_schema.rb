# frozen_string_literal: true

require 'dry-schema'

SubDeleteSchema = Dry::Schema.Params do
  required(:confirmation).filled(true)
end
