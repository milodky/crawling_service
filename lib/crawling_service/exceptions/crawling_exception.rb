module CrawlingService
  module CrawlingException
    class UndefinedMiddlewareError < StandardError; end

    class InitializationError < StandardError
      def initialize(*_)
        super('Failed to find the url or configure the middlewares!')
      end

    end

  end
end