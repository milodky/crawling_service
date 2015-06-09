module CrawlingService
  class Crawler::Middleware

    def initialize(*_)
    end

    def call(*_)
      raise CrawlingException::UndefinedMiddlewareError.new
    end
  end

end