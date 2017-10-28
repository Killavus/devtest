module TargetEvaluation
  class DeterminePrice
    Invalid = Class.new(StandardError)

    def initialize(hierarchies_db)
      @hierarchies_db = hierarchies_db
    end

    def call(form, current_panel_provider, all_locations)
      country = Country.find_by!(
        country_code: form.country_code,
        panel_provider: current_panel_provider
      )
      target_group = get_target_group(country, current_panel_provider, form)
      locations = match_locations_with_spec(all_locations, form)

      base_price = calculate_base_price(current_panel_provider, locations, form)
      total_panel_size = form.locations.map(&:panel_size).sum
      depth_modifier = calculate_depth_modifier(target_group)

      # FIXME: Wrap to use decimals or introduce Money object.
      (base_price * total_panel_size) / depth_modifier
    rescue ActiveRecord::RecordNotFound => err
      raise Invalid.new('Country or Target Group not found')
    end

    private
      def calculate_base_price(panel_provider, locations, form)
        evaluation_strategy = TargetEvaluation::EvaluationStrategy
          .for_panel_provider(panel_provider)
        provider_price = evaluation_strategy.()
        (provider_price + locations.length)
      end

      def match_locations_with_spec(all_locations, form)
        location_ids = form.locations.map(&:id)
        all_locations.find_all do |location|
          location_ids.include?(location.id)
        end.tap do |result|
          if result.length < form.locations.length
            raise Invalid.new('Locations spec contains invalid locations')
          end
        end
      end

      def get_target_group(country, panel_provider, form)
        target_group_ar = TargetGroup.find_by!(
          panel_provider: panel_provider,
          id: form.target_group_id
        )

        find_target_group_node(target_group_ar, country, panel_provider)
      end

      def find_target_group_node(target_group_ar, country, panel_provider)
        available_hierarchies = hierarchies_db.for_country(country, panel_provider)

        found_hierarchy = available_hierarchies.find do |hierarchy|
          hierarchy.node(target_group_ar.name).present?
        end

        if available_hierarchies.blank?
          raise Invalid.new(
            'Target group not a part of hierarchies available for this country.'
          )
        end

        found_hierarchy.node(target_group_ar.name)
      end

      def calculate_depth_modifier(target_group)
        cursor = target_group
        depth_modifier = 0

        while cursor.present?
          cursor = cursor.parent
          depth_modifier += 1
        end

        depth_modifier
      end

      attr_reader :hierarchies_db
  end
end
