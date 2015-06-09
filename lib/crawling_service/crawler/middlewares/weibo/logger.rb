require 'bunny'
module CrawlingService
  module Weibo
    class Logger < Crawler::Middleware

      LOGIN_URL = 'http://login.weibo.cn/login/?rand=1103689512&backURL=http%3A%2F%2Fweibo.cn%2F&backTitle=%E5%BE%AE%E5%8D%9A&vt=1&revalid=2&ns=1'
      FLAG      = 'div.c div span.ctt'
      # not sure what should be passed here
      def initialize(params = {})
        @params = params
        @bunny_options = RabbitMQOptions.new(params)
        @rabbit = RabbitMQClient.new(@bunny_options.to_hash)

      end

      # must have this method
      # basically overwrite the original one
      # no callback currently
      def call(env)
        logger(env)
      end

      def logger(env)
        page = env[:page]
        return if page.nil?

        weibo = page.search(FLAG)
        details = weibo.map(&:text)
        puts details.inspect
        puts
        @rabbit.publish(details)
      end

    end

    class RabbitMQOptions < Struct.new(:hostname, :host, :port, :username, :password, :vhost)
      def initialize(params)
        params.each { |k, v| self[k] = v}
        if self[:host].nil? && self[:hostname].nil?
          raise ArgumentError.new('Missing endpoint for RabbitMQ!')
        end
      end

      def delete(key)
        value = self[key]
        self[key] = nil
        value
      end

      def to_hash
        {}.tap { |h| members.each { |member| h[member] = self[member] if self[member] } }
      end
    end

    # still quite naive
    class RabbitMQClient
      def initialize(params)
        @connection = Bunny.new(params)
        @connection.start
        @channel = @connection.create_channel
        @queue   = @channel.queue('weibo_logger') # weibo logger is the routing key
      end

      def publish(messages)
        messages = Array.wrap(messages)
        messages.each do |message|
          begin
            @channel.default_exchange.publish(message, :routing_key => @queue.name, :persistent => true)
          rescue => err
            sleep(1)
            CrawlingService.log(err.message)
            CrawlingService.log(err.backtrace)
            retry
          end


        end

      end

    end
  end
end
