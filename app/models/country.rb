class Country < ActiveRecord::Base
  belongs_to :panel_provider
  validates :country_code, :panel_provider, presence: true 
end
