class Location < ActiveRecord::Base
  belongs_to :panel_provider

  validates :panel_provider, :name, presence: true
end
