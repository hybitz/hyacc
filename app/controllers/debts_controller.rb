class DebtsController < Base::HyaccController
  view_attribute :finder, :class => DebtFinder, :only => :index
  view_attribute :branches, :only => :index
  # 流動資産のみ対象
  view_attribute :accounts, :only => :index, :conditions => "path like '%" + ACCOUNT_CODE_CURRENT_ASSETS + "%'"

  def index
    @debts, @sum = finder.list if finder.commit
    setup_view_attributes
  end

  # 仮負債を精算する
  def create
    begin
      closed_id = do_close(params, current_user)
      # 選択した勘定科目をカウント
      save_input_frequencies(params)
      
      render :partial => 'closed_link', :locals => {:closed_id => closed_id}
    rescue => e
      handle(e)
      head :internal_server_error
    end
  end

  private

  def save_input_frequencies(params)
    InputFrequency.save_input_frequency(current_user.id, INPUT_TYPE_DEBT_ACCOUNT_ID, params['account_id'], params['sub_account_id'])
  end

  # 仮負債を精算する
  def do_close(params, user)
    split = params[:ymd].split('-')
    params[:ym] = split[0..1].join
    params[:day] = split[2]

    jh = Journal.find(params[:journal_id])
    # 締め状態のチェック用
    old = Journal.find(params[:journal_id])

    params[:jh] = jh
    a = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_DEBT)
    jh.journal_details.where(:account_id => a.id, :branch_id => params[:branch_id]).each do |jd|
      params[:jd] = jd
    end

    # 仮負債仕訳
    jh.transaction do
      param = Auto::Journal::TemporaryDebtParam.new(params, user)
      factory = Auto::AutoJournalFactory.get_instance( param )
      factory.make_journals
      JournalUtil.validate_closing_status_on_update(jh, old)
      jh.save!
    end
    jh.transfer_journals.last.id
  end

  def setup_view_attributes
    @ymd = params[:ymd] || Date.today.end_of_month

    # 直近で選択した勘定科目
    @frequency = InputFrequency.where(:user_id => current_user.id, :input_type => INPUT_TYPE_DEBT_ACCOUNT_ID).order('updated_at desc').first
  end

end
