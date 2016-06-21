module GengouHelper

  def to_wareki(year)
    TaxJp::Gengou.to_wareki(year)
  end

  def to_seireki(gengou, wareki)
    TaxJp::Gengou.to_seireki(gengou, wareki) 
  end

end