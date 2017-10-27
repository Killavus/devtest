require 'test_helper'

module Api::Private
  ExamplesController = Class.new(BaseController) do
    def index
    end
  end

  class BaseControllerTest < ActionController::TestCase
    tests ExamplesController

    def test_misconfigured_app_is_handled_properly
      jwt_secret = (ENV['JWT_SECRET'] || '').dup
      ENV['JWT_SECRET'] = ''

      get_index('123456')

      assert_response :internal_server_error
      assert_equal(
        { "error" => "IdentityAccess::Errors::Misconfigured" },
        json_body
      )

      ENV['JWT_SECRET'] = jwt_secret
    end

    def test_authentication_errors_are_handled_properly
      jwt_secret = (ENV['JWT_SECRET'] || '').dup
      ENV['JWT_SECRET'] = default_jwt_secret

      error_tokens = {
        nil => 'IdentityAccess::Errors::MissingCredentials',
        '' => 'IdentityAccess::Errors::MissingCredentials',
        '1234' => 'IdentityAccess::Errors::InvalidCredentials',
        jwt_token_generator('bad_secret') => 'IdentityAccess::Errors::InvalidCredentials'
      }

      error_tokens.each do |token, expected_error|
        #request.headers['Authentication'] = "Bearer #{token}"
        get_index(token)

        assert_response :unauthorized
        assert_equal(
          { "error" => expected_error },
          json_body,
          "Expected error #{expected_error} for token #{token.inspect}"
        )
      end

      ENV['JWT_SECRET'] = jwt_secret
    end

    private

    def default_jwt_secret
      'hello'
    end

    def get_index(token)
      with_routing do |set|
        set.draw do
          namespace :api do
            namespace :private do
              resources :examples, only: [:index]
            end
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
