require 'test_helper'

module Private
  class TargetEvaluationsControllerTest < ActionController::TestCase
    def test_different_provider_strategies_are_used_to_calculate_price
      target_group_1 = hierarchies_db.
        for_country(@country_1, @panel_1).
        first.
        root_node.
        children[0]

      target_group_2 = hierarchies_db.
        for_country(@country_2, @panel_2).
        first.
        root_node.
        children[0]

      target_group_3 = hierarchies_db.
        for_country(@country_3, @panel_3).
        first.
        root_node.
        children[0]

      call_create(@panel_1, @country_1, target_group_1)
      assert_response :ok
      assert_equal({ "price" => 1400 }, json_body)

      call_create(@panel_2, @country_2, target_group_2)
      assert_response :ok
      assert_equal({ "price" => 200 }, json_body)

      call_create(@panel_3, @country_3, target_group_3)
      assert_response :ok
      assert_equal({ "price" => 400 }, json_body)
    end

    def test_depth_of_node_counts_in_calculating_price
      target_group = hierarchies_db.
        for_country(@country_1, @panel_1).
        first.
        root_node

      call_create(@panel_1, @country_1, target_group)
      assert_response :ok
      assert_equal({ "price" => 2800 }, json_body)
    end

    def test_invalid_country_is_rejected
      target_group = hierarchies_db.
        for_country(@country_1, @panel_1).
        first.
        root_node.
        children[0]

      call_create(@panel_1, @country_2, target_group)

      assert_response :unprocessable_entity
      assert_equal({
        "error" => 'ActiveRecord::RecordNotFound',
        "message" => "Couldn't find Country"
      }, json_body)
    end

    def test_invalid_target_group_is_rejected
      target_group = hierarchies_db.
        for_country(@country_2, @panel_2).
        first.
        root_node.
        children[0]

      call_create(@panel_1, @country_1, target_group)
      assert_response :unprocessable_entity

      assert_equal({
        "error" => 'TargetEvaluation::DeterminePrice::Invalid',
        "message" => 'Country or Target Group not found'
      }, json_body)
    end

    def test_invalid_locations_are_rejected
      target_group = hierarchies_db.
        for_country(@country_1, @panel_1).
        first.
        root_node.
        children[0]

      call_create(@panel_1, @country_1, target_group, [{ id: 333, panel_size: 32 }])
      assert_equal({
        "error" => 'TargetEvaluation::DeterminePrice::Invalid',
        "message" => 'Locations spec contains invalid locations'
      }, json_body)
    end

    private

    def call_create(panel_provider, country, target_group, own_locations_spec = nil)
      locations_spec = [@location_1, @location_2].map do |loc|
        { panel_size: 100, id: loc.id }
      end

      locations_spec = own_locations_spec if own_locations_spec.present?

      params = {
        country_code: country.country_code,
        target_group_id: target_group.__ar.id,
        locations: locations_spec
      }

      token = IdentityAccess::JwtTokenGenerator.new(ENV['JWT_SECRET']).
        generate(panel_provider_id: panel_provider.id, private_api: true)

      request.headers['Authorization'] = "Bearer #{token}"
      request.headers['Content-Type'] = 'application/json'
      request.headers['Accept'] = 'application/json'
      post :create, params
    end

    def setup
      @prev_jwt_secret = (ENV['JWT_SECRET'] || '').dup
      ENV['JWT_SECRET'] = default_jwt_secret

      @panel_1 = PanelProvider.create!(code: 'TIMES_A')
      @panel_2 = PanelProvider.create!(code: 'TIMES_HTML')
      @panel_3 = PanelProvider.create!(code: '10_ARRAYS')

      @country_1 = Country.create!(country_code: 'PL', panel_provider: @panel_1)
      @country_2 = Country.create!(country_code: 'GB', panel_provider: @panel_2)
      @country_3 = Country.create!(country_code: 'JP', panel_provider: @panel_3)

      @location_1 = Location.create!(name: 'Loc1', secret_code: SecureRandom.hex)
      @location_2 = Location.create!(name: 'Loc2', secret_code: SecureRandom.hex)

      @location_group_1 = LocationGroup.create!(
        name: 'LocGr1',
        panel_provider: @panel_1,
        country: @country_1
      )

      @location_group_1.locations << @location_1
      @location_group_1.locations << @location_2

      @location_group_2 = LocationGroup.create!(
        name: 'LocGr2',
        panel_provider: @panel_2,
        country: @country_2
      )

      @location_group_2.locations << @location_1
      @location_group_2.locations << @location_2

      @location_group_3 = LocationGroup.create!(
        name: 'LocGr3',
        panel_provider: @panel_3,
        country: @country_3
      )

      @location_group_3.locations << @location_1
      @location_group_3.locations << @location_2

      hierarchy_1 = TargetGroups::Hierarchy.new(
        name: 'H1 Root',
        panel_provider: @panel_1,
        secret_code: SecureRandom.hex,
        countries: [@country_1]
      )

      hierarchy_1.
        root_node.
          add_child(name: 'H1 Node', secret_code: SecureRandom.hex)

      hierarchy_2 = TargetGroups::Hierarchy.new(
        name: 'H2 Root',
        panel_provider: @panel_2,
        secret_code: SecureRandom.hex,
        countries: [@country_2]
      )

      hierarchy_2.
        root_node.
          add_child(name: 'H2 Node', secret_code: SecureRandom.hex)

      hierarchy_3 = TargetGroups::Hierarchy.new(
        name: 'H3 Root',
        panel_provider: @panel_3,
        secret_code: SecureRandom.hex,
        countries: [@country_3]
      )

      hierarchy_3.
        root_node.
          add_child(name: 'H3 Node', secret_code: SecureRandom.hex)

      hierarchies_db.store(hierarchy_1)
      hierarchies_db.store(hierarchy_2)
      hierarchies_db.store(hierarchy_3)

      stub_request(:any, 'time.com').to_return(
        status: 200, body: time_com_stubbed_body
      )
      stub_request(:any, 'openlibrary.org/search.json?q=the%20lord%20of%20the%20rings').to_return(
        status: 200, body: lotr_stubbed_body
      )
    end

    def teardown
      ENV['JWT_SECRET'] = @prev_jwt_secret
    end

    def hierarchies_db
      @hierarchies_db ||= TargetGroups::HierarchyDb.new
    end

    def time_com_stubbed_body
      <<-TIMESCOM
      <!doctype html>
      <html>
      <head>
        <meta charset="UTF-8" />
        <title>time.com</title>
      </head>
      <body>
        <p><a href="#">test</a> letters aaaaaaaaaaaa</p>
      </body>
      </html>

      TIMESCOM
    end

    def lotr_stubbed_body
      {
        something: 1,
        something_else: 'foo',
        one_big: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        second_big: ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l'],
        small_one: [1, 2, 3]
      }.to_json
    end

    def default_jwt_secret
      'thesecret'
    end
  end
end
