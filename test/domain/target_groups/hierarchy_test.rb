require 'test_helper'

module TargetGroups
  class HierarchyTest < ActiveSupport::TestCase
    def setup
      @panel_provider = PanelProvider.create!(code: 'TIMES_A')
      @country = Country.create!(country_code: 'PL', panel_provider: @panel_provider)
      @secret_codes = []
    end

    def generate_code
      SecureRandom.hex.tap do |secret_code|
        @secret_codes << secret_code
      end
    end

    def test_hierarchy_can_be_stored_and_loaded_again
      new_hierarchy = Hierarchy.new(
        panel_provider: @panel_provider,
        secret_code: generate_code,
        name: 'IT Employees'
      )

      new_hierarchy.
        root_node.
          add_child(name: 'Software Developers', secret_code: generate_code).
          add_child(name: 'Testers & QAs', secret_code: generate_code)

      new_hierarchy.
        node('Software Developers').
          add_child(name: 'Python Developers', secret_code: generate_code).
          add_child(name: 'Java Developers', secret_code: generate_code)

      new_hierarchy.
        node('Testers & QAs').
          add_child(name: 'Hardware Testers', secret_code: generate_code)

      new_hierarchy.
        link_country(@country)

      hierarchy_db = HierarchyDb.new
      hierarchy_db.store(new_hierarchy)

      loaded_hierarchy = hierarchy_db.for_country(@country).first

      assert_hierarchy_structure({
        name: 'IT Employees',
        panel_provider: @panel_provider,
        countries: [@country],
        secret_code: @secret_codes[0],
        children: [
          {
            name: 'Software Developers',
            secret_code: @secret_codes[1],
            children: [
              {
                name: 'Python Developers',
                secret_code: @secret_codes[3],
                children: []
              },
              {
                name: 'Java Developers',
                secret_code: @secret_codes[4],
                children: []
              }
            ]
          },
          {
            name: 'Testers & QAs',
            secret_code: @secret_codes[2],
            children: [
              {
                name: 'Hardware Testers',
                secret_code: @secret_codes[5],
                children: []
              }
            ]
          }
        ]
      }, loaded_hierarchy)
    end

    private

    def assert_hierarchy_structure(expected, hierarchy)
      assert_root_metadata(expected, hierarchy)

      bfs_queue = [
        [nil, hierarchy.root_node, expected]
      ]

      while bfs_queue.length > 0
        expected_parent, current, expected_node = bfs_queue.shift

        if expected_parent.present?
          assert_equal(expected_parent, current.parent)
        else
          assert_nil(current.parent)
        end

        assert_equal(expected_node[:name], current.name)
        assert_equal(expected_node[:secret_code], current.secret_code)

        expected_node[:children].each_with_index do |expected_children, i|
          bfs_queue << [current, current.children[i], expected_children]
        end
      end
    end

    def assert_root_metadata(expected, hierarchy)
      assert_equal(expected[:panel_provider], hierarchy.root_node.panel_provider)
      expected[:countries].each do |country|
        assert_includes(hierarchy.countries, country)
      end
    end
  end
end
