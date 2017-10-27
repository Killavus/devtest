require 'test_helper'

module IdentityAccess
  class JwtTokenAuthenticationTest < ActiveSupport::TestCase
    def test_valid_token_produces_session
      Timecop.freeze do
        valid_token = jwt_token_generator.generate(panel_provider_id: 112)

        api_session = jwt_token_auth.make_session!(valid_token)

        assert_equal(112, api_session.panel_provider_id)
        assert_equal(Time.now.advance(hours: 1).to_i, api_session.expires_at.to_i)
        assert_equal(false, api_session.private_api)
      end
    end

    def test_valid_private_token_produces_private_api_session
      Timecop.freeze do
        valid_token = jwt_token_generator.generate(panel_provider_id: 112, private_api: true)

        api_session = jwt_token_auth.make_session!(valid_token)

        assert_equal(112, api_session.panel_provider_id)
        assert_equal(Time.now.advance(hours: 1).to_i, api_session.expires_at.to_i)
        assert_equal(true, api_session.private_api)
      end
    end

    def test_missing_token_is_rejected
      assert_raises(IdentityAccess::Errors::MissingCredentials) do
        jwt_token_auth.make_session!(nil)
      end
    end

    def test_expired_token_is_rejected
      expired_token = nil
      Timecop.travel(Time.now.advance(days: -2)) do
        expired_token = jwt_token_generator.generate(panel_provider_id: 112)
      end

      assert_raises(IdentityAccess::Errors::ExpiredCredentials) do
        jwt_token_auth.make_session!(expired_token)
      end
    end

    def test_bad_token_is_rejected
      bad_token = 'something bad'

      assert_raises(IdentityAccess::Errors::InvalidCredentials) do
        jwt_token_auth.make_session!(bad_token)
      end
    end

    def test_invalid_secret_token_is_rejected
      bad_secret_token = jwt_token_generator('badsecret').
        generate(panel_provider_id: 112)

      assert_raises(IdentityAccess::Errors::InvalidCredentials) do
        jwt_token_auth.make_session!(bad_secret_token)
      end
    end

    def test_generating_tokens_without_secret_is_impossible
      assert_raises(IdentityAccess::Errors::Misconfigured) do
        jwt_token_generator(nil)
      end
    end

    def test_session_generation_without_secret_is_impossible
      assert_raises(IdentityAccess::Errors::Misconfigured) do
        jwt_token_auth(nil)
      end
    end

    private

    def jwt_token_generator(jwt_secret = default_jwt_secret)
      JwtTokenGenerator.new(jwt_secret)
    end

    def jwt_token_auth(jwt_secret = default_jwt_secret)
      JwtTokenAuth.new(jwt_secret)
    end

    def default_jwt_secret
      "TEST_SECRET"
    end
  end
end
