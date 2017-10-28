module Private
  class TargetEvaluationsController < BaseController
    def create
      render json: { price: determine_price.(form) }
    end

    private

    def form
      @form ||= TargetEvaluation::Form.new(params)
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
