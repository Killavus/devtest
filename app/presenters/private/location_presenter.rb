module Private
  class LocationPresenter
    def as_json(collection)
      collection.map(&method(:location_as_json))
    end

    private

    def location_as_json(location)
      {
        id: location.id,
        name: location.name,
        secret_code: location.secret_code
      }
    end
  end
end
