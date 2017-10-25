require 'test_helper'

module IdentityAccess
  class JwtTokenAuthenticationTest < ActiveSupport::TestCase
    def test_missing_token_is_rejected
      assert_raises(IdentityAccess::Errors::Unauthorized) do
        jwt_token_auth.authorize!(nil)
      end
    end

    private

    def jwt_token_auth
      @jwt_token_auth ||= JwtTokenAuth.new("TEST_SECRET")
    end

    def jwt_secret
      "TEST_SECRET"
    end
  end
end
