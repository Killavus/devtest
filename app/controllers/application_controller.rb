class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  rescue_from IdentityAccess::Errors::Error, with: :access_error
  rescue_from IdentityAccess::Errors::Misconfigured, with: :app_misconfigured
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  respond_to :json
  before_action :authorize!

  private

  def authorize!
    extracted_token = (request.authorization || '').gsub(/Bearer\s+/, '')

    @current_api_session = IdentityAccess::JwtTokenAuth.
      new(ENV['JWT_SECRET']).
      make_session!(extracted_token)
  end

  def error_payload(error)
    { error: error.class.to_s }.tap do |payload|
      payload.merge!(message: error.message) if error.message != error.class.to_s
    end
  end

  def not_found(err)
    render json: error_payload(err), status: :not_found
  end

  def app_misconfigured(err)
    render json: error_payload(err), status: :internal_server_error
  end

  def access_error(err)
    render json: error_payload(err), status: :unauthorized
  end

  def current_panel_provider
    PanelProvider.find(@current_api_session.panel_provider_id)
  end
end
