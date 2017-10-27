class Country < ActiveRecord::Base
  belongs_to :panel_provider
  validates :country_code, :panel_provider, presence: true 

  has_many :target_groups, through: :country_target_group_assignments
  has_many :country_target_group_assignments
end
