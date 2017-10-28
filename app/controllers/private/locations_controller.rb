module Private
  class LocationsController < BaseController
    include CountryCodeScoped

    def index
      locations = fetch_locations_for_country.(country, current_panel_provider)

      render json: location_presenter.as_json(locations)
    end

    private

    def location_presenter
      @location_presenter ||= Private::LocationPresenter.new
    end

    def fetch_locations_for_country
      @fetch_locations_for_country ||= FetchLocationsForCountry.new
    end
  end
end
