require 'crawling_service/version'
require 'crawling_service/crawler/crawler'
require 'crawling_service/crawler/middlewares/middleware'
require 'crawling_service/crawler/middlewares/weibo/login'
require 'crawling_service/crawler/middlewares/weibo/logger'
require 'crawling_service/crawler/middlewares/weibo/process'
require 'crawling_service/exceptions/crawling_exception'

require 'mechanize'
require 'active_support/all'
require 'logger'
module CrawlingService
  # Your code goes here...
  def self.configure(&block)
    if block_given?
      block.call(self)
    else

    end
  end

  def self.logger(path)
    file = File.open(path, 'w+')
    @logger = Logger.new(file)
  end

  def self.log(message)
    @logger.info(message)
  end


end
