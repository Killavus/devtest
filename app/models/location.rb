class Location < ActiveRecord::Base
  validates :name, :secret_code, presence: true
end
