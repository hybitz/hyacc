require 'hyacc_master/service_factory'

class SocialInsuranceFinder < Daddy::Model

  def list
    service = HyaccMaster::ServiceFactory.create_service(Rails.env)
    service.get_insurances(prefecture_code, ym.gsub('-', ''), base_salary)
  end

  def prefectures
    @prefectures ||= TaxJp::Prefecture.all.map{|x| [x.name, x.code] }
  end

end
