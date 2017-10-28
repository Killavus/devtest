require 'test_helper'

class LocationsControllerTest < ActionController::TestCase
  def setup
    @prev_jwt_secret = (ENV['JWT_SECRET'] || '').dup
    ENV['JWT_SECRET'] = default_jwt_secret
    @panel_provider = PanelProvider.create!(code: "TIMES_A")
    @country = Country.create!(country_code: 'PL', panel_provider: @panel_provider)
    @secret_codes = []
  end

  def teardown
    ENV['JWT_SECRET'] = @prev_jwt_secret
  end

  def test_list_endpoint_returns_proper_json
    location_group = LocationGroup.create!(
      panel_provider: @panel_provider,
      country: @country,
      name: "Test Group"
    )

    location_1 = Location.create!(name: 'Location 1', secret_code: generate_code).reload
    location_2 = Location.create!(name: 'Location 2', secret_code: generate_code).reload
    location_3 = Location.create!(name: 'Location 3', secret_code: generate_code).reload

    location_group.locations << location_1
    location_group.locations << location_2
    location_group.save

    get_index

    assert_equal([
      {
        "id" => location_1.external_id,
        "name" => "Location 1"
      },
      {
        "id" => location_2.external_id,
        "name" => "Location 2"
      }
    ], json_body)
  end

  def generate_code
    SecureRandom.hex.tap do |code|
      @secret_codes << code
    end
  end

  def get_index
    auth_token = IdentityAccess::JwtTokenGenerator.
      new(default_jwt_secret).
      generate(panel_provider_id: @panel_provider.id)

    request.headers['Authorization'] = "Bearer #{auth_token}"
    get :index, country_id: @country.country_code
  end

  def default_jwt_secret
    "odelay"
  end
end
