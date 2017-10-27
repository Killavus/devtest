class PanelProvider < ActiveRecord::Base
  validates :code, presence: true
end
