class LocationGroup < ActiveRecord::Base
  belongs_to :country
  belongs_to :panel_provider

  validates :name, :country, :panel_provider, presence: true

  has_many :locations, through: :location_group_assignments
  has_many :location_group_assignments
end
