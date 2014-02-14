# coding: UTF-8
#
# $Id: pension_finder.rb 3113 2013-08-06 04:01:04Z ichy $
# Product: hyacc
# Copyright 2009-2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class PensionFinder < Base::Finder
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
    pensions = []

    Net::HTTP.version_1_2
    Net::HTTP.start(HYACC_MASTER_URL, 80) {|http|
      response = http.get("/user/pension/list?ym=#{@ym}&baseSalary=#{@base_salary}")
      json = ActiveSupport::JSON.decode(response.body)
      json.each do |j|
        pen = Pension.new
        pen.apply_start_ym = j['startYm'].to_i
        pen.apply_end_ym = j['endYm'].to_i
        pen.grade = j['grade'].to_i
        pen.pay_range_above = j['startSalary'].to_i
        pen.pay_range_under = j['endSalary'].to_i
        pen.monthly_earnings = j['baseSalary'].to_i
        pen.pension = j['pension'].to_i
        pen.pension_half = j['pensionHalf'].to_i
        pen.pension2 = j['pension2'].to_i
        pen.pension2_half = j['pension2Half'].to_i
        pensions << pen
      end
    }
    
    pensions
  end
end
