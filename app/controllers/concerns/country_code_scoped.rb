module CountryCodeScoped
  extend ActiveSupport::Concern

  included do
    def country
      @country ||= Country.find_by!(
        country_code: params[:country_id],
        panel_provider: current_panel_provider
      )
    end
  end
end
