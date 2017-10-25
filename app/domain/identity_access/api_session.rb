module IdentityAccess
  class ApiSession < Dry::Struct::Value
    attribute :panel_provider_id, ::Types::Coercible::Int
    attribute :expires_at, ::Types::DateTime
  end
end
