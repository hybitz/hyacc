# -*- encoding : utf-8 -*-
#
# $Id: hyacc_util.rb 3120 2013-08-12 08:41:31Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module HyaccUtil
  include HyaccConstants
  include HyaccErrors
  include HyaccDateUtil

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

  def receipt_save_dir(jh)
    "receipt/" + (jh.ym * 100 + jh.day).to_s
  end
  
  # ファイルの保存 TODO 更新時には使えない（日時で保存のため、ファイル名が重複する）
  def save_receipt_file(dir, file)
    create_dir(File.join(UPLOAD_DIRECTORY, dir))

    # 日本語ファイル名は、保存不可
    filename = FileColumn::sanitize_filename("#{file.original_filename}")
    db_path = File.join(dir, filename)
    
    if File.exist?(File.join(UPLOAD_DIRECTORY, db_path))
      raise HyaccException.new(ERR_FILE_ALREADY_EXISTS)
    end
    File.open(File.join(UPLOAD_DIRECTORY, db_path), "wb"){ |f| f.write(file.read) }
    
    return db_path
  end

  # アップロードファイル削除
  def delete_upload_file(receipt_path)
    path = File.join(UPLOAD_DIRECTORY, receipt_path)
    File.delete(path) if File.exist?(path)
  end
  
  # 再帰的にディレクトリを作成
  def create_dir(path_to_dir)
    d = ""
    # 先頭が"/"でない場合は、カレントディレクトリから
    if path_to_dir[0,1] != "/"
      d = "."
    end
    
    path_to_dir.split("/").each do |x|
      d = File.join(d, x)
      unless File.exists?(d)
        Dir::mkdir(d)
      end
    end
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
