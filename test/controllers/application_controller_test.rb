require 'test_helper'

ExamplesController = Class.new(ApplicationController) do
  def index
    render json: { code: current_panel_provider.code }
  end
end

class ApplicationControllerTest < ActionController::TestCase
  tests ExamplesController

  def test_authentication_errors_are_handled_properly
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
  end

  def test_properly_authorized_request_have_access_to_panel_provider
    get_index(jwt_token_generator.generate(panel_provider_id: @panel_provider.id, private_api: true))

    assert_response :ok
    assert_equal(
      { "code" => "TIMES_1" },
      json_body
    )
  end

  def test_misconfigured_app_is_handled_properly
    ENV['JWT_SECRET'] = ''

    get_index('123456')

    assert_response :internal_server_error
    assert_equal(
      { "error" => "IdentityAccess::Errors::Misconfigured" },
      json_body
    )
  end

  private

    def setup
      @prev_jwt_secret = (ENV['JWT_SECRET'] || '').dup
      @panel_provider = PanelProvider.create!(code: 'TIMES_1')
      ENV['JWT_SECRET'] = default_jwt_secret
    end

    def teardown
      @panel_provider.destroy
      ENV['JWT_SECRET'] = @prev_jwt_secret
    end

    def default_jwt_secret
      'hello'
    end

    def get_index(token)
      with_routing do |set|
        set.draw do
          resources :examples, only: [:index]
        end

        request.headers['Authorization'] = "Bearer #{token}"
        get :index
      end
    end

    def jwt_token_generator(secret = default_jwt_secret)
      IdentityAccess::JwtTokenGenerator.new(secret)
    end
end
