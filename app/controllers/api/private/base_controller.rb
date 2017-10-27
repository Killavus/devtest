module Api::Private
  class BaseController < ::ApplicationController
    rescue_from IdentityAccess::Errors::Error, with: :access_error
    rescue_from IdentityAccess::Errors::Misconfigured, with: :app_misconfigured

    before_action :authorize!

    private

    def app_misconfigured(err)
      render json: error_payload(err), status: :internal_server_error
    end

    def access_error(err)
      render json: error_payload(err), status: :unauthorized
    end

    def error_payload(error)
      { error: error.class.to_s }
    end

    def authorize!
      extracted_token = (request.authorization || '').gsub(/Bearer\s+/, '')

      @current_session ||= IdentityAccess::JwtTokenAuth.
        new(ENV['JWT_SECRET']).
        make_session!(extracted_token)
    end
  end
end
