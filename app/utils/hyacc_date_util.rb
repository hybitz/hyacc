module HyaccDateUtil

  def self.to_date(yyyymmdd)
    Date.new(yyyymmdd/10000, yyyymmdd/100%100, yyyymmdd%100)
  end
  
  def self.to_int(date)
    date.year * 10000 + date.month * 100 + date.day
  end

  # 年度初年月を取得
  # 年初月が7月以降の場合は、前年からが会計年度とする
  # 例：年初月が12月の場合、2007年度の始まりは2006年12月から
  def self.get_start_year_month_of_fiscal_year(fiscal_year, start_month_of_fiscal_year)
    if start_month_of_fiscal_year > 6
      start_year = fiscal_year.to_i - 1
    else
      start_year = fiscal_year.to_i
    end
    
    start_year * 100 + start_month_of_fiscal_year
  end
  
  # 年度末年月を取得
  def self.get_end_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year )
    start_year_month = get_start_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year )
    start_year = start_year_month / 100
    start_month = start_year_month % 100
    
    if start_month == 1
      end_year = start_year
      end_month = 12
    else
      end_year = start_year + 1
      end_month = start_month - 1
    end
    
    end_year * 100 + end_month
  end

  # 年月がその年度の12ヶ月の何番目の月か（0ベース）
  def self.get_ym_index( start_month_of_fiscal_year, ym )
    month = ym % 100
    ret = month - start_month_of_fiscal_year
    ret += 12 if ret < 0
    ret
  end

  # 指定年月からNヶ月分の年月配列を作成する
  def self.get_year_months( year_month_from, number_of_months )
    year = year_month_from / 100
    month = year_month_from % 100  

    ret = []
    
    number_of_months.times { |i|
      ret << year * 100 + month

      if month == 12
        year += 1
        month = 1
      else
        month += 1
      end
    }
    
    ret
  end

  # 月末の日付を取得
  def self.get_days_of_month(year, month)
    Date.new( year, month, -1 ).day
  end
  
  # 指定した年の前後を含めた年のリストを作成する
  # @param ym 年
  # @param before 前何年分かを指定
  # @param after 後何年分かを指定
  def self.get_ym_list(ym, before, after)
    ym - before .. ym + after
  end
 
  # 月末の日を取得します。
  # @param ym 年月（yyyymm）
  def self.last_day_of_month(ym)
    Date.new( ym/100, ym%100, -1 ).day
  end
  
  # 前月を取得します。
  def self.last_month(ym)
    year = ym / 100
    month = ym % 100
    
    month = month - 1
    if month == 0
      month = 12
      year = year - 1
    end
    
    year * 100 + month
  end
  
  # 次月を取得します。
  def self.next_month( ym )
    year = ym / 100
    month = ym % 100
    
    month = month + 1
    if month == 13
      month = 1
      year = year + 1
    end
    
    year * 100 + month
  end
  
  # 月を加算した年月を取得します。
  def self.add_months(ym, num_of_months)
    year = ym / 100
    month = ym % 100

    years_to_add = num_of_months / 12
    months_to_add = num_of_months % 12

    year += years_to_add
    month += months_to_add
    
    if month / 12 != 0
      year += month / 12
      month = month % 12
      if month == 0
        year -= 1
        month = 12
      end
    end
    
    year * 100 + month
  end
  
  # 年度にymを含めて後何ヶ月残っているか
  def self.get_remaining_months(start_month_of_fiscal_year, ym)
    12 - get_ym_index(start_month_of_fiscal_year, ym)
  end

  def self.weekday_of_month(yyyy, mm)
    date_range = (Date.new(yyyy, mm, 1)..Date.new(yyyy, mm, -1))
    date_range.select(&method(:weekday?)).count
  end
  
  def self.weekday?(date)
    !(date.saturday? || date.sunday? || HolidayJp.holiday?(date))
  end
end
