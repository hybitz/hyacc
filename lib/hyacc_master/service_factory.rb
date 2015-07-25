module HyaccMaster
  TAX_JP = false

  class ServiceFactory
    require 'hyacc_master/cache'
    require 'hyacc_master/mock'
    
    def self.create_service(env)
      if HyaccMaster::TAX_JP
        return HyaccMaster::Service.new
      end

      case env
      when 'production', 'development'
        HyaccMaster::Cache.new
      when 'test'
        HyaccMaster::Mock.new
      else
        raise "不明な環境です。env=#{env}"
      end
    end
  end
end
