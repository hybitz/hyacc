require 'hyacc_master/service_factory'

class PensionFinder < Daddy::Model

  def list
    service = HyaccMaster::ServiceFactory.create_service(Rails.env)
    service.get_pensions(prefecture_code, ym.gsub('-', ''), base_salary)
  end

  def prefectures
    @prefectures ||= TaxJp::Prefecture.all.map{|x| [x.name, x.code] }
  end

end
