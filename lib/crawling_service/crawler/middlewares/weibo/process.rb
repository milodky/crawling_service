module CrawlingService
  module Weibo
    class Process < Crawler::Middleware

      LOGIN_URL = 'http://login.weibo.cn/login/?rand=1103689512&backURL=http%3A%2F%2Fweibo.cn%2F&backTitle=%E5%BE%AE%E5%8D%9A&vt=1&revalid=2&ns=1'
      FLAG      = 'div.u div.tip2 a'
      URL       = 'http://weibo.cn'
      FOLLOWER_FLAG = 'table'
      # must have this method
      # basically overwrite the original one
      # no callback currently


      def call(env)
        process(env)
      end

      def process(env)
        return if env[:page].nil?
        # try_login, write the url back to env
        urls(env)
      end

      ###############################################################
      # try to login to weibo phone version
      #
      def urls(env)
        begin
          page = env[:page]
          agent = env[:agent]
          follower_url = page.search(FLAG)[1].attributes['href'].value
          follower_page = agent.get(follower_url)
          tables = follower_page.search(FOLLOWER_FLAG)
          tables.map{|table| get_url_from_table(table)}
        rescue => err
          CrawlingService.log(err.message)
          CrawlingService.log(err.backtrace)
          []
        end

      end

      def get_url_from_table(table)
        table.at_css('tr td a').attributes['href'].value
      end
    end
  end
end
