module CrawlingService
  class Crawler
    module Configuration

      def before_crawling(middleware, *args)
        @pre_middlewares << middleware.new(*args)
      end

      def after_crawling(middleware, *args)
        @post_middlewares << middleware.new(*args)
      end

      def in_crawling(middleware, *args)
        @in_middleware = middleware.new(*args)
      end

    end

  end
end