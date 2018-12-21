module GengouHelper

  def to_wareki(year, only_year: false)
    TaxJp::Gengou.to_wareki(year.to_i, :only_year => only_year)
  end

  def to_seireki(gengou, wareki)
    TaxJp::Gengou.to_seireki(gengou, wareki) 
  end

  def heisei?(d)
    TaxJp::Gengou.to_wareki(d.year.to_i).start_with?("平成")
  end

  def syowa?(d)
    TaxJp::Gengou.to_wareki(d.year.to_i).start_with?("昭和")
  end
  
  def taisyo?(d)
    TaxJp::Gengou.to_wareki(d.year.to_i).start_with?("大正")
  end
  
  def meiji?(d)
    TaxJp::Gengou.to_wareki(d.year.to_i).start_with?("明治")
  end
end