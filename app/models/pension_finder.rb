require 'hyacc_master/service_factory'

class PensionFinder < Daddy::Model

  def list
    service = HyaccMaster::ServiceFactory.create_service(Rails.env)
    service.get_pensions(ym.gsub('-', ''), base_salary)
  end

end
