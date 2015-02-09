module HyaccMaster
  class ServiceFactory
    require 'hyacc_master/cache'
    require 'hyacc_master/mock'
    
    def self.create_service(env)
      case env
      when 'production', 'development'
        return HyaccMaster::Cache.new
      when 'test'
         return HyaccMaster::Mock.new
      else
        raise "不明な環境です。env=#{env}"
      end
    end
  end
end
