# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

PANEL_PROVIDER_CODES = [
  'TIMES_A',
  '10_ARRAYS',
  'TIMES_HTML'
]

COUNTRIES = [
  { code: 'PL', panel_provider_code: 'TIMES_A' },
  { code: 'JP', panel_provider_code: '10_ARRAYS' },
  { code: 'UK', panel_provider_code: 'TIMES_HTML' }
]

LOCATION_GROUPS = [
  { name: 'Polish Cities', panel_provider_code: 'TIMES_A', country: 'PL' },
  { name: 'Japanese Cities', panel_provider_code: '10_ARRAYS', country: 'JP' },
  { name: 'British Cities', panel_provider_code: 'TIMES_HTML', country: 'UK' },
  { name: 'Polish Sea', panel_provider_code: 'TIMES_A', country: 'PL' }
]

LOCATIONS = [
  { name: 'Wrocław', location_groups: ['Polish Cities'], secret_code: SecureRandom.hex },
  { name: 'Warszawa', location_groups: ['Polish Cities'], secret_code: SecureRandom.hex },
  { name: 'Kraków', location_groups: ['Polish Cities'], secret_code: SecureRandom.hex },
  { name: 'Sopot', location_groups: ['Polish Cities', 'Polish Sea'], secret_code: SecureRandom.hex },
  { name: 'Gdynia', location_groups: ['Polish Cities', 'Polish Sea'], secret_code: SecureRandom.hex },
  { name: 'Gdańsk', location_groups: ['Polish Cities', 'Polish Sea'], secret_code: SecureRandom.hex },
  { name: 'Koszalin', location_groups: ['Polish Cities', 'Polish Sea'], secret_code: SecureRandom.hex },
  { name: 'Tokio', location_groups: ['Japanese Cities'], secret_code: SecureRandom.hex },
  { name: 'Kyoto', location_groups: ['Japanese Cities'], secret_code: SecureRandom.hex },
  { name: 'Osaka', location_groups: ['Japanese Cities'], secret_code: SecureRandom.hex },
  { name: 'Yokohama', location_groups: ['Japanese Cities'], secret_code: SecureRandom.hex },
  { name: 'Sapporo', location_groups: ['Japanese Cities'], secret_code: SecureRandom.hex },
  { name: 'London', location_groups: ['British Cities'], secret_code: SecureRandom.hex },
  { name: 'Birmingham', location_groups: ['British Cities'], secret_code: SecureRandom.hex },
  { name: 'Edinburgh', location_groups: ['British Cities'], secret_code: SecureRandom.hex },
  { name: 'Liverpool', location_groups: ['British Cities'], secret_code: SecureRandom.hex },
  { name: 'Bristol', location_groups: ['British Cities'], secret_code: SecureRandom.hex },
  { name: 'Glasgow', location_groups: ['British Cities'], secret_code: SecureRandom.hex },
  { name: 'Leeds', location_groups: ['British Cities'], secret_code: SecureRandom.hex },
  { name: 'Oxford', location_groups: ['British Cities'], secret_code: SecureRandom.hex }
]

ActiveRecord::Base.transaction do
  if ENV['PURGE'] then
    LocationGroupAssignment.destroy_all
    Location.destroy_all
    LocationGroup.destroy_all
    Country.destroy_all
    PanelProvider.destroy_all
  end

  PANEL_PROVIDER_CODES.each do |panel_code|
    PanelProvider.create!(code: panel_code)
  end

  COUNTRIES.each do |country|
    panel_provider = PanelProvider.find_by!(code: country[:panel_provider_code])
    Country.create!(panel_provider: panel_provider, country_code: country[:code])
  end

  LOCATION_GROUPS.each do |location_group|
    country = Country.find_by!(country_code: location_group[:country])
    panel_provider = PanelProvider.find_by!(code: location_group[:panel_provider_code])

    LocationGroup.create!(
      panel_provider: panel_provider,
      country: country,
      name: location_group[:name]
    )
  end

  LOCATIONS.each do |location|
    Location.create!(
      secret_code: location[:secret_code],
      name: location[:name]
    ).tap do |record|
      location[:location_groups].each do |group_name|
        location_group = LocationGroup.find_by!(name: group_name)

        LocationGroupAssignment.create!(location: record, location_group: location_group)
      end
    end
  end
end
