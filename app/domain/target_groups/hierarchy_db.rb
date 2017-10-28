module TargetGroups
  class HierarchyDb
    StoreFailed = Class.new(StandardError)

    def store(hierarchy)
      ActiveRecord::Base.transaction do
        persist_all_nodes(hierarchy)
        persist_country_linkages(hierarchy)
      end
    end

    def for_country(country, panel_provider)
      hierarchy_root_nodes = CountryTargetGroupAssignment.
        joins(target_group: [:panel_provider]).
        where(country: country, target_groups: { panel_provider_id: panel_provider.id }).
        map(&:target_group)

      hierarchy_countries = CountryTargetGroupAssignment.
        preload(:country).
        where(target_group_id: hierarchy_root_nodes.map(&:id)).
        group_by(&:target_group_id).
        transform_values { |assignments| assignments.map(&:country) }

      root_hierarchies = hierarchy_root_nodes.map do |root_node|
        hierarchy = Hierarchy.new(
          panel_provider: root_node.panel_provider,
          name: root_node.name,
          secret_code: root_node.secret_code,
          __ar: root_node,
          countries: hierarchy_countries[root_node.id]
        )
      end

      populate_hierarchies(root_hierarchies)
    end

    private

    def populate_hierarchies(root_hierarchies)
      root_hierarchies.tap do
        parent_nodes = root_hierarchies.map(&:root_node)

        while parent_nodes.length > 0
          child_nodes = TargetGroup.
            preload(:panel_provider).
            where(parent: parent_nodes.map(&:__ar))

          added_child_nodes = child_nodes.map do |child|
            # FIXME: Linear time search can be optimized here
            # by introducing a lookup hash.
            parent_node = parent_nodes.find do |node|
              node.__ar.id == child.parent_id
            end

            parent_node.into_add_child(
              name: child.name,
              secret_code: child.secret_code,
              __ar: child
            )
          end

          parent_nodes = added_child_nodes
        end
      end
    end

    def persist_all_nodes(hierarchy)
      hierarchy.each(&method(:persist_node))
    end

    def persist_node(node)
      return if node.__ar.present?
      parent_ar = node.parent.try(:__ar)

      node_ar = TargetGroup.create!(
        panel_provider: node.panel_provider,
        secret_code: node.secret_code,
        name: node.name,
        parent: parent_ar
      ).reload

      node.__ar = node_ar
    rescue ActiveRecord::RecordInvalid => err
      raise StoreFailed.new(err.message)
    end

    def persist_country_linkages(hierarchy)
      root_node_ar = hierarchy.root_node.__ar

      all_country_ids = hierarchy.countries.map(&:id)
      persisted_country_ids = CountryTargetGroupAssignment.where(
        target_group_id: root_node_ar.id
      ).map(&:country_id)

      (all_country_ids - persisted_country_ids).each do |new_country_id|
        CountryTargetGroupAssignment.create!(
          target_group: root_node_ar,
          country_id: new_country_id
        )
      end
    end
  end
end
