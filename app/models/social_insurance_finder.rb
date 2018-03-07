class SocialInsuranceFinder
  include ActiveModel::Model

  attr_accessor :ym
  attr_accessor :prefecture_code
  attr_accessor :base_salary
  
  def list
    TaxUtils.get_social_insurances(prefecture_code, ym.gsub('-', ''), base_salary)
  end

  def prefectures
    @prefectures ||= TaxJp::Prefecture.all.map{|x| [x.name, x.code] }
  end

end
