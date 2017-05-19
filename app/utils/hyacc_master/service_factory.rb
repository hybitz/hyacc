module HyaccMaster
  class ServiceFactory
    
    def self.create_service(env)
      return HyaccMaster::TaxJp.new
    end

  end
end
