class TargetGroupsController < ApplicationController
  include CountryCodeScoped

  def index
    hierarchies = target_group_hierarchies_db.for_country(
      country,
      current_panel_provider
    )

    render json: target_group_presenter.as_json(hierarchies)
  end

  private

  def target_group_presenter
    @target_group_presenter ||= TargetGroupPresenter.new
  end

  def target_group_hierarchies_db
    @target_group_hierarchies_db ||= TargetGroups::HierarchyDb.new
  end
end
