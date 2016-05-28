class AccountTransfersController < Base::HyaccController
  include JournalHelper
  include AccountTransferHelper
  include AssetUtil

  view_attribute :title => '科目振替'
  helper_method :finder

  def index
    @journals = finder.list if finder.commit
  end

  def update_details
    form = params[:form]
    finder.to_account_id = params[:finder][:to_account_id].to_i
    finder.to_sub_account_id = params[:finder][:to_sub_account_id].to_i

    unless form and form[:details].present?
      redirect_to :action => :index, :commit => true and return
    end

    begin
      a = Account.get(finder.to_account_id)
      sa = a.get_sub_account_by_id(finder.to_sub_account_id) if finder.to_sub_account_id > 0
      journals = {}

      a.transaction do
        form[:details].each do |detail|
          next unless detail[1].to_i == 1

          jh_id, lock_version, jd_id = /jh_([0-9]+)_lv_([0-9]+)_jd_([0-9]+)/.match(detail[0]).to_a.values_at(1, 2, 3)

          if HyaccLogger.debug?
            HyaccLogger.debug "jh_id=#{jh_id}, lock_version=#{lock_version}, jd_id=#{jd_id}"
          end

          jh = JournalHeader.find(jh_id)
          old_jh = jh.copy
          raise HyaccException.new(ERR_INVALID_ACTION) unless can_edit(jh)

          jd = jh.journal_details.find(jd_id)
          raise HyaccException.new(ERR_INVALID_ACTION) unless can_transfer_account(jd)

          jd.account_id = a.id
          if sa
            jd.sub_account_id = sa.id
          else
            jd.sub_account_id = nil
          end
          jd.save!

          journals.store("#{jh.id}", lock_version) unless journals.has_key?("#{jh.id}")
          jh.lock_version = journals["#{jh.id}"]

          AssetUtil.validate_assets(jh, old_jh)
          Auto::AutoJournalUtil.do_auto_transfers(jh)
          JournalUtil.validate_journal(jh, old_jh)
          jh.save!

          journals.store("#{jh.id}", jh.lock_version.to_i)
        end
      end

      flash[:notice] = '科目を一括振替しました。'
    rescue => e
      handle(e)
    end

    redirect_to :action => :index, :finder => params[:finder], :commit => true
  end

  private

  def finder
    unless @finder
      @finder = AccountTransferFinder.new(params[:finder])
      @finder.company_id = current_company.id
      @finder.slip_type_selection ||= SLIP_TYPE_TRANSFER
      @finder.branch_id ||= current_user.employee.default_branch.id
      @finder.commit = params[:commit].present?
      @finder.page = params[:page]
      @finder.per_page = current_user.slips_per_page
    end

    @finder
  end

end
