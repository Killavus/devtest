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
  { name: 'Wrocław', location_groups: ['Polish Cities'] },
  { name: 'Warszawa', location_groups: ['Polish Cities'] },
  { name: 'Kraków', location_groups: ['Polish Cities'] },
  { name: 'Sopot', location_groups: ['Polish Cities', 'Polish Sea'] },
  { name: 'Gdynia', location_groups: ['Polish Cities', 'Polish Sea'] },
  { name: 'Gdańsk', location_groups: ['Polish Cities', 'Polish Sea'] },
  { name: 'Koszalin', location_groups: ['Polish Cities', 'Polish Sea'] },
  { name: 'Tokio', location_groups: ['Japanese Cities'] },
  { name: 'Kyoto', location_groups: ['Japanese Cities'] },
  { name: 'Osaka', location_groups: ['Japanese Cities'] },
  { name: 'Yokohama', location_groups: ['Japanese Cities'] },
  { name: 'Sapporo', location_groups: ['Japanese Cities'] },
  { name: 'London', location_groups: ['British Cities'] },
  { name: 'Birmingham', location_groups: ['British Cities'] },
  { name: 'Edinburgh', location_groups: ['British Cities'] },
  { name: 'Liverpool', location_groups: ['British Cities'] },
  { name: 'Bristol', location_groups: ['British Cities'] },
  { name: 'Glasgow', location_groups: ['British Cities'] },
  { name: 'Leeds', location_groups: ['British Cities'] },
  { name: 'Oxford', location_groups: ['British Cities'] }
]

TARGET_GROUPS = [
  {
    name: 'IT',
    country_codes: ['PL', 'JP'],
    panel_provider_code: 'TIMES_A',
    children: [
      {
        name: 'Software Developers',
        children: [
          { name: 'Python Developers', children: [] },
          { name: 'Java Developers', children: [] }
        ]
      },
      {
        name: 'QA & Testers',
        children: []
      }
    ]
  },
  {
    name: 'Investors',
    country_codes: ['UK'],
    panel_provider_code: '10_ARRAYS',
    children: [
      {
        name: 'VC Investors',
        children: [
          { name: 'Angel Investors', children: [] }
        ]
      }
    ]
  },
  {
    name: 'Journalists',
    country_codes: ['UK', 'PL'],
    panel_provider_code: 'TIMES_HTML',
    children: [
      {
        name: 'Press Journalists',
        children: []
      },
      {
        name: 'YouTube Journalists',
        children: [
          { name: 'Game Dev Journalists', children: [] }
        ]
      }
    ]
  },
  {
    name: 'Butchers',
    country_codes: ['JP'],
    panel_provider_code: 'TIMES_HTML',
    children: [
      {
        name: 'Poultry Butchers',
        children: [
          { name: 'Turkey Butchers', children: [] }
        ]
      }
    ]
  }
]

def destroy_target_groups!
  # Since we have strict database checking of foreign keys,
  # we need to preserve order in which we destroy target groups - from leaves to nodes.
  # It is usually called topological sort and we're doing it here indirectly.

  nodes_in_rtopo_order = TargetGroup.where(parent_id: nil)
  node_level = TargetGroup.where(parent_id: nil)

  while node_level.length > 0
    next_node_level = TargetGroup.where(parent: node_level)
    nodes_in_rtopo_order += next_node_level
    node_level = next_node_level
  end

  ActiveRecord::Base.transaction do
    nodes_in_rtopo_order.reverse.each do |node|
      node.destroy
    end
  end
end

ActiveRecord::Base.transaction do
  if ENV['PURGE'] then
    LocationGroupAssignment.destroy_all
    Location.destroy_all
    LocationGroup.destroy_all
    CountryTargetGroupAssignment.destroy_all
    destroy_target_groups!
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
      secret_code: SecureRandom.hex,
      name: location[:name]
    ).tap do |record|
      location[:location_groups].each do |group_name|
        location_group = LocationGroup.find_by!(name: group_name)

        LocationGroupAssignment.create!(location: record, location_group: location_group)
      end
    end
  end

  target_group_hierarchy_db = TargetGroups::HierarchyDb.new

  TARGET_GROUPS.each do |group|
    panel_provider = PanelProvider.find_by(code: group[:panel_provider_code])
    hierarchy = TargetGroups::Hierarchy.new(
      name: group[:name],
      secret_code: SecureRandom.hex,
      panel_provider: panel_provider
    )

    group[:country_codes].each do |country_code|
      hierarchy.link_country(Country.find_by!(country_code: country_code))
    end

    queue = [[hierarchy.root_node, group[:children]]]

    while queue.length > 0
      parent, children_spec = queue.shift

      children_spec.each do |child_spec|
        queue << [
          parent.into_add_child(
            name: child_spec[:name],
            secret_code: SecureRandom.hex
          ),
          child_spec[:children]
        ]
      end
    end

    target_group_hierarchy_db.store(hierarchy)
  end
end
