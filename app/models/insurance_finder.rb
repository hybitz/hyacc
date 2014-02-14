# coding: UTF-8
#
# $Id: insurance_finder.rb 2957 2012-11-09 07:45:31Z ichy $
# Product: hyacc
# Copyright 2009-2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class InsuranceFinder < Base::Finder
  require 'hyacc_master/service_factory'
  include JournalUtil

  attr_accessor :ym
  attr_accessor :base_salary
  attr_accessor :grade_start
  attr_accessor :grade_end
  
  # 初期化
  def initialize( user )
    super( user )
    @ym = Time.new.strftime("%Y%m")
  end
  
  def setup_from_params( params )
    return unless params

    super( params )
    @base_salary = params[:base_salary]
    @grade_start = params[:grade_start]
    @grade_end = params[:grade_end]
  end
  
  def list
    service = HyaccMaster::ServiceFactory.create_service(Rails.env)
    service.get_insurances(@prefecture_id, @ym, @base_salary)
  end
end
