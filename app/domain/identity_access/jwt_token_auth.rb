module IdentityAccess
  class JwtTokenAuth
    def initialize(secret)
      @secret = secret
    end

    def authorize!(token)
      raise Errors::MissingCredentials.new('Please provide a valid token.')
    end

    private

    attr_reader :secret
  end
end
