require 'test_helper'

module Private
  class TargetGroupsControllerTest < ActionController::TestCase
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
      hierarchy = TargetGroups::Hierarchy.new(
        name: 'Test',
        secret_code: generate_code,
        panel_provider: @panel_provider,
        countries: [@country]
      )

      hierarchy.
        root_node.
        into_add_child(name: 'Test 2', secret_code: generate_code).
        into_add_child(name: 'Test 3', secret_code: generate_code)

      TargetGroups::HierarchyDb.new.store(hierarchy)

      get_index

      assert_response :ok
      assert_equal([
        {
          "country_ids" => [@country.id],
          "nodes" => [
            {
              "id" => TargetGroup.find_by(name: 'Test').id,
              "name" => "Test",
              "secret_code" => @secret_codes[0],
              "parent_id" => nil
            },
            {
              "id" => TargetGroup.find_by(name: 'Test 2').id,
              "name" => "Test 2",
              "secret_code" => @secret_codes[1],
              "parent_id" => TargetGroup.find_by(name: 'Test').id
            },
            {
              "id" => TargetGroup.find_by(name: 'Test 3').id,
              "name" => "Test 3",
              "secret_code" => @secret_codes[2],
              "parent_id" => TargetGroup.find_by(name: 'Test 2').id
            }
          ]
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
        generate(panel_provider_id: @panel_provider.id, private_api: true)

      request.headers['Authorization'] = "Bearer #{auth_token}"
      get :index, country_id: @country.country_code
    end

    def default_jwt_secret
      "odelay"
    end
  end
end
