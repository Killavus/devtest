module Private
  class BaseController < ::ApplicationController
    private

      def authorize!
        super

        raise IdentityAccess::Errors::AccessDenied.new unless @current_api_session.private_api
      end
  end
end
