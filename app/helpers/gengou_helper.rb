module GengouHelper

  def to_wareki(year, only_year: false)
    TaxJp::Gengou.to_wareki(year.to_i, :only_year => only_year)
  end

  def to_seireki(gengou, wareki)
    TaxJp::Gengou.to_seireki(gengou, wareki) 
  end

end