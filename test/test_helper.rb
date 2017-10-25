ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # Add more helper methods to be used by all tests here...

  class TestTimeAdapter
    def now
      Time.new(2017, 10, 25, 20, 24, 33, "+02:00")
    end
  end
end
