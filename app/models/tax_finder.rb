# coding: UTF-8
#
# $Id: tax_finder.rb 3174 2014-01-09 14:57:15Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class TaxFinder < Base::Finder 
  include JournalUtil

  attr_accessor :include_has_tax
  attr_accessor :include_nontaxable
  attr_accessor :include_checked
  
  def setup_from_params( params )
    super(params)
    
    return unless params

    @include_has_tax = params[:include_has_tax].to_i
    @include_nontaxable = params[:include_nontaxable].to_i
    @include_checked = params[:include_checked].to_i
  end
  
  def list
    return nil unless commit
    
    JournalHeader.find(:all, :conditions=>make_conditions,
      :include=>[:journal_details],
      :joins=>'inner join tax_admin_infos on journal_headers.id = tax_admin_infos.journal_header_id',
      :order=>"ym desc, day desc, journal_headers.created_on desc").reverse
  end

  def count
    JournalHeader.count(:all, :conditions=>make_conditions,
      :joins=>'inner join tax_admin_infos on journal_headers.id = tax_admin_infos.journal_header_id')
  end

protected
  # 検索条件を作成する
  def make_conditions
    conditions = []
    
    # 年月
    conditions[0] = "ym >= ? "
    conditions << get_start_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year )
    conditions[0] << "and ym <= ? "
    conditions << get_end_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year )
    
    # 伝票区分
    conditions[0] << "and slip_type in (?, ?, ?) "
    conditions << SLIP_TYPE_SIMPLIFIED
    conditions << SLIP_TYPE_TRANSFER
    conditions << SLIP_TYPE_AUTO_TRANSFER_LEDGER_REGISTRATION

    # 検索キー
    conditions[0] << "and finder_key rlike ? "
    conditions << build_rlike_condition( nil, 0, branch_id )

    # 消費税を含む伝票も含むかどうか
    unless include_has_tax.to_i == 1
      conditions[0] << "and finder_key not rlike ? and finder_key not rlike ? "
      conditions << build_rlike_condition( ACCOUNT_CODE_TEMP_PAY_TAX, 0, 0 )
      conditions << build_rlike_condition( ACCOUNT_CODE_SUSPENSE_TAX_RECEIVED, 0, 0 )
    end

    # 非課税のみで構成されている伝票も含むかどうか
    if include_nontaxable.to_i == 1
      conditions[0] << "and should_include_tax = ? "
      conditions << false
    else
      conditions[0] << "and should_include_tax = ? "
      conditions << true
    end
    
    # 確認フラグ
    if include_checked.to_i == 1
      conditions[0] << "and checked = ? "
      conditions << true
    else
      conditions[0] << "and checked = ? "
      conditions << false
    end
    
    conditions
  end

end
