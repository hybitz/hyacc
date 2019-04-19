module GengouHelper

  def to_wareki(date, only_date: false, format: nil)
    if format
      TaxJp::Gengou.to_wareki(date, only_date: only_date, format: format)
    else
      TaxJp::Gengou.to_wareki(date, only_date: only_date)
    end
  end

  def to_wareki_year(year, only_date: false)
    TaxJp::Gengou.to_wareki(Date.new(year.to_i, 12, 31), only_date: only_date, format: '%y')
  end

  def to_seireki(gengou, wareki)
    TaxJp::Gengou.to_seireki(gengou, wareki) 
  end

  def heisei?(date)
    TaxJp::Gengou.to_wareki(date).start_with?("平成")
  end

  def syowa?(date)
    TaxJp::Gengou.to_wareki(date).start_with?("昭和")
  end
  
  def taisyo?(date)
    TaxJp::Gengou.to_wareki(date).start_with?("大正")
  end
  
  def meiji?(date)
    TaxJp::Gengou.to_wareki(date).start_with?("明治")
  end
end