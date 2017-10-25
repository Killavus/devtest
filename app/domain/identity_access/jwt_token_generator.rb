module IdentityAccess
  class JwtTokenGenerator
    def initialize(secret)
      @secret = secret
      raise Errors::Misconfigured.new if secret.blank?
    end

    def generate(panel_provider_id:)
      JWT.encode(
        { data: { panel_provider_id: panel_provider_id }, exp: Time.now.advance(hours: 1).to_i },
        secret,
        'HS256'
      )
    end

    private

    attr_reader :secret
  end
end
