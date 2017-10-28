class LocationPresenter
  def as_json(collection)
    collection.map(&method(:location_as_json))
  end

  private

  def location_as_json(location)
    {
      id: location.external_id,
      name: location.name
    }
  end
end
