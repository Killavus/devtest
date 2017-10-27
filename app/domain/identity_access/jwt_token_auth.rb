module IdentityAccess
  class JwtTokenAuth
    def initialize(secret)
      @secret = secret
      raise Errors::Misconfigured.new if secret.blank?
    end

    def make_session!(token)
      raise Errors::MissingCredentials.new if token.blank?

      decoded_token = JWT.decode(token, secret, true, algorithm: 'HS256').first

      ApiSession.new(
        panel_provider_id: decoded_token['data']['panel_provider_id'],
        private_api: decoded_token['data']['private_api'],
        expires_at: Time.at(decoded_token['exp'])
      )
    rescue JWT::ExpiredSignature
      raise Errors::ExpiredCredentials.new
    rescue JWT::DecodeError
      raise Errors::InvalidCredentials.new
    end

    private

    attr_reader :secret
  end
end
