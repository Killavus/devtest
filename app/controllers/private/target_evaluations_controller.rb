module Private
  class TargetEvaluationsController < BaseController
    def create
      country = Country.find_by!(
        panel_provider: current_panel_provider,
        country_code: form.country_code
      )

      price = determine_price.(
        form,
        current_panel_provider,
        fetch_locations_for_country.(country, current_panel_provider)
      )

      render json: { price: price }
    rescue TargetEvaluation::DeterminePrice::Invalid, ActiveRecord::RecordNotFound => err
      render json: error_payload(err), status: :unprocessable_entity
    rescue TargetEvaluation::EvaluationStrategy::EvaluationFailed => err
      raise json: error_payload(err), status: :bad_gateway
    end

    private

    def fetch_locations_for_country
      @fetch_locations_for_country ||= FetchLocationsForCountry.new
    end

    def form
      TargetEvaluation::Form.new(params)
    end

    def determine_price
      @determine_price ||= TargetEvaluation::DeterminePrice.new(
        target_group_hierarchies_db
      )
    end

    def target_group_hierarchies_db
      @target_group_hierarchies_db ||= TargetGroups::HierarchyDb.new
    end
  end
end
