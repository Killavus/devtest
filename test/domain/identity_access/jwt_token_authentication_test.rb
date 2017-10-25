require 'test_helper'

module IdentityAccess
  class JwtTokenAuthenticationTest < ActiveSupport::TestCase
    def test_missing_token_is_rejected
      assert_raises(IdentityAccess::Errors::MissingCredentials) do
        jwt_token_auth.authorize!(nil)
      end
    end

    def test_valid_token_produces_session
      valid_token = jwt_token_generator.generate(panel_provider_id: 112)

      api_session = jwt_token_auth.authorize!(valid_token)

      assert_equal(112, api_session.panel_provider_id)
      assert_equal(time_adapter.now.advance(hours: 1), api_session.expires_at)
    end

    private

    def jwt_token_generator(jwt_secret = default_jwt_secret)
      JwtTokenGenerator.new(time_adapter, jwt_secret)
    end

    def jwt_token_auth(jwt_secret = default_jwt_secret)
      JwtTokenAuth.new(jwt_secret)
    end

    def time_adapter
      TestTimeAdapter.new
    end

    def default_jwt_secret
      "TEST_SECRET"
    end
  end
end
