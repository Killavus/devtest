module TargetGroups
  class Hierarchy
    class Node
      include Equalizer.new(:name, :secret_code, :panel_provider, :parent)

      def initialize(
        name:,
        secret_code:,
        panel_provider:,
        parent:,
        __ar: nil
      )
        @name = name
        @secret_code = secret_code
        @panel_provider = panel_provider
        @parent = parent
        @__ar = __ar
        @children = []
      end

      def add_child(name:, secret_code:, __ar: nil)
        panel_provider = __ar.try(:panel_provider) || self.panel_provider

        Node.new(
          name: name,
          secret_code: secret_code,
          panel_provider: panel_provider,
          parent: self,
          __ar: __ar
        ).tap do |new_child|
          @children << new_child
        end
      end

      attr_reader :name, :parent, :secret_code, :panel_provider, :__ar, :children
      attr_writer :__ar
    end

    class HierarchyNode
      include Equalizer.new(:hierarchy, :node)

      extend Forwardable

      def_delegators :@node,
        :panel_provider,
        :secret_code,
        :name,
        :__ar,
        :__ar=

      def initialize(hierarchy, node)
        @hierarchy = hierarchy
        @node = node
      end

      def add_child(**kwargs)
        self.tap { node_add_child(**kwargs) }
      end

      def into_add_child(**kwargs)
        HierarchyNode.new(
          hierarchy,
          node_add_child(**kwargs)
        )
      end

      def parent
        return nil if node.parent.blank?

        HierarchyNode.new(
          hierarchy,
          node.parent
        )
      end

      def children
        node.children.map do |child|
          HierarchyNode.new(hierarchy, child)
        end
      end

      private

      def node_add_child(**kwargs)
        node.add_child(**kwargs).tap do |new_child|
          hierarchy.update_lookup_map(new_child)
        end
      end

      attr_reader :node, :hierarchy
    end

    def initialize(
      panel_provider:,
      secret_code:,
      name:,
      __ar: nil,
      countries: []
    )
      @countries = countries
      @root_node = Node.new(
        panel_provider: panel_provider,
        secret_code: secret_code,
        name: name,
        parent: nil,
        __ar: __ar
      )

      @nodes_lookup = { @root_node.name => @root_node }
    end

    def link_country(country)
      @countries << country unless @countries.include?(country)
    end

    def node(name)
      HierarchyNode.new(self, @nodes_lookup[name])
    end

    def update_lookup_map(new_node)
      @nodes_lookup[new_node.name] = new_node
    end

    def root_node
      HierarchyNode.new(self, @root_node)
    end

    attr_reader :countries
  end
end
