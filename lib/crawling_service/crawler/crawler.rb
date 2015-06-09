require 'crawling_service/crawler/configuration'
module CrawlingService
  class Crawler
    include Configuration
    CONFIG = {
        :crawling_depth => 2,
        :timeout        => 10

    }.with_indifferent_access

    #############################################################
    # initialize a web crawler
    #
    def initialize(params = {}, &block)
      params ||= {}
      raise ArgumentError.new('The input must be a hash!') unless params.is_a?Hash
      @params              = Marshal.load(Marshal.dump(params)).with_indifferent_access
      CONFIG.merge!(params)
      puts CONFIG
      @pre_middlewares     = []
      @in_middleware       = nil
      @post_middlewares    = []
      @agent               = Mechanize.new
      @params[:agent]      = @agent unless @params[:agent]
      block.call(self) if block_given?
    end


    #############################################################
    # the method to trigger crawling
    #
    def start_crawling
      begin
      if @params[:url]
        page = @agent.get(@params[:url])
      else
        @pre_middlewares.each { |mw| mw.call(@params) }
        page = @params[:page]
        raise 'internal error' if page.nil?
      end
      rescue => _
        raise CrawlingException::InitializationError.new
      end

      # starting from Depth 0
      process(page, 0)
    end

    #############################################################
    # the real working part of the crawling process
    #
    def process(page, depth)
      return if page.nil? || depth >= @params.fetch(:crawling_depth, CONFIG[:crawling_depth])
      get_sub_pages(page, :agent => @agent).each do |sub_page|
        begin
          process(sub_page, depth + 1)
          sleep(1)
        rescue Mechanize::UnsupportedSchemeError => _
          $stderr.puts 'Error: Found link with unsupported scheme, trying another'
        rescue Mechanize::ResponseCodeError => err
          $stderr.puts "Error: #{err.message}"
        end

      end
      log(page)
    end

    def get_sub_pages(page, options = {})
      return if page.nil?
      begin
        Timeout.timeout(CONFIG[:timeout]) do
          if @in_middleware
            @in_middleware.call(options.merge(:page => page)).map{|url| @agent.get(url)}
          else
            page.links.map(&:click)
          end
        end
      rescue TimeoutError => err
        $stderr.puts "Error: Timeout(#{err.message})"
        []
      end
    end

    def log(page)
      @post_middlewares.map {|mv| mv.call(:page => page)}
    end


  end
end