module CountryCodeScoped
  extend ActiveSupport::Concern

  included do
    def country
      @country ||= Country.find_by!(country_code: params[:country_id])
    end
  end
end
