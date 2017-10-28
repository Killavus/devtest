module TargetEvaluation
  class Form < Dry::Struct
    class LocationSpec < Dry::Struct
      attribute :id, ::Types::Coercible::Int
      attribute :panel_size, ::Types::Coercible::Int
    end

    attribute :target_group_id, ::Types::Coercible::Int
    attribute :country_code, ::Types::String
    attribute :locations, ::Types::Array.member(LocationSpec)
  end
end
