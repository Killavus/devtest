require 'test_helper'

module Private
  ExamplesController = Class.new(BaseController) do
    def index; end
  end

  class BaseControllerTest < ActionController::TestCase
    tests ExamplesController

    def test_non_private_api_sessions_are_rejected
      get_index(jwt_token_generator.generate(panel_provider_id: 123))

      assert_response :unauthorized
      assert_equal(
        { "error" => "IdentityAccess::Errors::AccessDenied" },
        json_body
      )
    end

    private

      def default_jwt_secret
        'private'
      end

      def setup
        @prev_jwt_secret = (ENV['JWT_SECRET'] || '').dup
        ENV['JWT_SECRET'] = default_jwt_secret
      end

      def teardown
        ENV['JWT_SECRET'] = @prev_jwt_secret
      end

      def get_index(token)
        with_routing do |set|
          set.draw do
            namespace :private do
              resources :examples, only: [:index]
            end
          end

          request.headers['Authorization'] = "Bearer #{token}"
          get :index
        end
      end

      def jwt_token_generator(secret = default_jwt_secret)
        IdentityAccess::JwtTokenGenerator.new(secret)
      end
  end
end
