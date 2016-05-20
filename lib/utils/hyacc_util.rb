require 'digest/md5'

module HyaccUtil
  include HyaccConstants
  include HyaccErrors
  include HyaccDateUtil

  def self.hashed_filename(filename)
    "#{Digest::MD5.file(filename)}#{File.extname(filename)}"
  end

  def add( amount1, amount2 )
    ret = 0
    ret += amount1.nil? ? 0 : amount1
    ret += amount2 unless amount2.nil?
    ret
  end

  def subtract( amount1, amount2 )
    ret = 0
    ret += amount1.nil? ? 0 : amount1
    ret -= amount2 unless amount2.nil?
    ret
  end
  
  # 反対の貸借区分を取得
  def opposite_dc_type( dc_type )
    dc_type == DC_TYPE_DEBIT ? DC_TYPE_CREDIT : DC_TYPE_DEBIT
  end

  # 分割した値を配列で返す
  # 割り切れない場合も合計が除算前になるように返す
  # 除数が０の場合は空の配列を返す
  # divede(10,3) = [4,3,3]
  def divide(a,b)
    a = a.to_i
    b = b.to_i
    result = []
    return result if b == 0
    c = a.divmod(b)
    b.times{result << c[0]}
    c[1].times{|i|
      result[i] += 1
    }
    return result
  end
  
  # ARを指定カラムでソートします。
  def sort(records, column_name)
    return nil unless records
    return records unless column_name
    return records if records.size == 0
    # メソッドが存在しない場合
    return records unless records[0].respond_to?(column_name)
    records.sort{|x, y| x.__send__(column_name) <=> y.__send__(column_name)}
  end
end
