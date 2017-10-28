module Private
  class LocationsController < BaseController
    include CountryCodeScoped

    def index
      locations = fetch_locations_for_country.(country, current_panel_provider)

      render json: locations_presenter.as_json(locations)
    end

    private

    def locations_presenter
      @locations_presenter ||= Private::LocationsPresenter.new
    end

    def fetch_locations_for_country
      @fetch_locations_for_country ||= FetchLocationsForCountry.new
    end
  end
end
