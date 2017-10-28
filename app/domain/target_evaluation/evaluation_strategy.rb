module TargetEvaluation
  class EvaluationStrategy
    EvaluationFailed = Class.new(StandardError)
    UnknownStrategy = Class.new(StandardError)

    def self.for_panel_provider(panel_provider)
      case panel_provider.code
        when "TIMES_A" then LetterCountStrategy.new(http_adapter)
        when "TIMES_HTML" then HtmlCountStrategy.new(http_adapter)
        when "10_ARRAYS" then BigArrayStrategy.new(http_adapter)
        else raise UnknownStrategy.new("Unknown panel provider code")
      end
    end

    def self.http_adapter
      ::HttpAdapter.new
    end
  end
end
