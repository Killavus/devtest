class LocationGroupAssignment < ActiveRecord::Base
  belongs_to :location_group
  belongs_to :location
end
