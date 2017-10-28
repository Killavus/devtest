module TargetEvaluation
  class DeterminePrice
    def initialize(hierarchies_db)
      @hierarchies_db = hierarchies_db
    end

    def call(form)

    end

    private
      attr_reader :hierarchies_db
  end
end
