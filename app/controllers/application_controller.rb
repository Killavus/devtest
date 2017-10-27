class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  rescue_from IdentityAccess::Errors::Error, with: :access_error
  rescue_from IdentityAccess::Errors::Misconfigured, with: :app_misconfigured

  before_action :authorize!

  private

  def authorize!
    extracted_token = (request.authorization || '').gsub(/Bearer\s+/, '')

    @current_api_session = IdentityAccess::JwtTokenAuth.
      new(ENV['JWT_SECRET']).
      make_session!(extracted_token)
  end

  def error_payload(error)
    { error: error.class.to_s }
  end

  def app_misconfigured(err)
    render json: error_payload(err), status: :internal_server_error
  end

  def access_error(err)
    render json: error_payload(err), status: :unauthorized
  end

  def current_panel_provider
    @current_panel_provider ||= PanelProvider.find(@current_api_session.panel_provider_id)
  end
end
