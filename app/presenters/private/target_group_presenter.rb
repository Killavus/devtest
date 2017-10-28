module Private
  class TargetGroupPresenter
    def as_json(collection)
      collection.map(&method(:hierarchy_as_json))
    end

    private

    def hierarchy_as_json(hierarchy)
      {
        country_ids: hierarchy.countries.map(&:id),
        nodes: hierarchy.map do |node|
          {
            name: node.name,
            id: node.__ar.id,
            secret_code: node.secret_code,
            parent_id: node.parent.try(:__ar).try(:id)
          }
        end
      }
    end
  end
end
