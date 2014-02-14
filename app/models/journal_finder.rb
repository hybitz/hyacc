# coding: UTF-8
#
# $Id: journal_finder.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class JournalFinder < Base::Finder
  include HyaccConstants

  attr_accessor :slip_type_selection
  attr_accessor :remarks

  def initialize(user)
    super(user)
    @slip_type_selection = 1
    @remarks = nil
  end
  
  def setup_from_params( params )
    return unless params
    
    super(params)
    @slip_type_selection = params[:slip_type_selection].to_i
    @remarks = params[:remarks]
  end

  def list
    conditions = make_conditions
    
    # 初期検索でページングしていない時は一番最後（直近）のページを表示する
    if @page == 0
      total_count = JournalHeader.count(:all, :conditions=>conditions)
      if total_count > 0
        @page = total_count / @slips_per_page + (total_count % @slips_per_page > 0 ? 1 : 0)

      end

      if @page == 0
        @page = 1
      end
    end
    
    # 伝票を取得
    JournalHeader.paginate(
      :page=>@page,
      :conditions => conditions,
      :order => "ym, day, created_on",
      :per_page => @slips_per_page)
  end
  
private
  def get_slip_types
    case @slip_type_selection
    when 1
      return [SLIP_TYPE_TRANSFER]
    when 2
      return [SLIP_TYPE_TRANSFER, SLIP_TYPE_SIMPLIFIED]
    when 3
      return [SLIP_TYPE_TRANSFER, SLIP_TYPE_SIMPLIFIED, SLIP_TYPE_AUTO_TRANSFER_LEDGER_REGISTRATION]
    when 4
      raise Exception.new('予期していない処理分岐です')    
    else
      return [-1]
    end
  end

  def make_conditions
    conditions = []
    conditions[0] = ""
    
    # 伝票区分
    if @slip_type_selection != 4
      conditions[0] << 'slip_type in ( '
      get_slip_types.each_with_index do |slip_type, i|
        conditions[0] << ', ' unless i == 0
        conditions[0] << '?'
        conditions << slip_type
      end
      conditions[0] << ') '
    end
    
    # 年月の指定がある場合
    if @ym.to_i > 0
      conditions[0] << "and " unless conditions[0].empty?
      conditions[0] << "ym like '?%' "
      conditions << @ym.to_i
    end
    
    # 勘定科目または部門の指定がある場合
    if @account_id > 0 or @branch_id > 0
      conditions[0] << "and " unless conditions[0].empty?
      conditions[0] << "finder_key rlike ? "

      # 勘定科目
      if @account_id > 0
        rlike = '.*-' + Account.find( @account_id ).code + ','
      else
        rlike = '.*-[0-9]*,'
      end
      
      # 補助科目
      rlike << '[0-9]*' + ','
      
      # 計上部門
      if @branch_id > 0
        rlike << @branch_id.to_s + '-.*'
      else
        rlike << '[0-9]*-.*'
      end
      
      conditions << rlike
    end

    # 摘要の指定がある場合
    unless @remarks.nil? or @remarks.empty?
      conditions[0] << "and " unless conditions[0].empty?
      conditions[0] << "remarks like ? "
      conditions << '%' + @remarks + '%'
    end
    
    # 条件がない場合はnilにする
    if conditions.length < 2
      conditions = nil
    end
    
    conditions
  end

end
