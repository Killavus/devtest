class TargetGroup < ActiveRecord::Base
  belongs_to :parent, class_name: 'TargetGroup'
  belongs_to :panel_provider

  validates :panel_provider, :name, :secret_code, presence: true
end
