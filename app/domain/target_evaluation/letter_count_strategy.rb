module TargetEvaluation
  class LetterCountStrategy
    def initialize(http_adapter)
      @http_adapter = http_adapter
    end

    def call
      body = http_adapter.get('http://time.com')

      html = Nokogiri::HTML(body)
      html.at('body').inner_text.count('a')
    rescue HttpAdapter::Failed
      raise TargetEvaluation::EvaluationStrategy::EvaluationFailed.new
    end

    private

    attr_reader :http_adapter
  end
end
