class FetchLocationsForCountry
  def call(country, panel_provider)
    groups = LocationGroup.preload(:locations).where(
      country: country,
      panel_provider: panel_provider
    )

    groups.flat_map(&:locations).uniq(&:id)
  end
end
