module TargetEvaluation
  class BigArrayStrategy
    def initialize(http_adapter)
      @http_adapter = http_adapter
    end

    def call
      response = http_adapter.get('http://openlibrary.org/search.json?q=the+lord+of+the+rings')
      json = JSON.parse(response)

      result = 0
      json.each do |kv|
        _, value = kv

        result += 1 if value.is_a?(Array) && value.size >= 10
      end

      result
    rescue HttpAdapter::Failed
      raise TargetEvaluation::EvaluationStrategy::EvaluationFailed.new
    end

    private

    attr_reader :http_adapter
  end
end
