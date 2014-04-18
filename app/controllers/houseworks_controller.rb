class HouseworksController < Base::HyaccController
  include JournalUtil
  
  available_for :type => :company_type, :only => COMPANY_TYPE_PERSONAL
  view_attribute :title => '家事按分'
  view_attribute :finder, :class => HouseworkFinder
  view_attribute :ym_list

  def index
    @hw = finder.list
  end
  
  def create_journal
    hw = Housework.find(params[:id])
    
    begin
      hw.transaction do
        param = Auto::Journal::HouseworkParam.new( hw, current_user )
        factory = Auto::AutoJournalFactory.get_instance( param )
        hw.journal_headers = factory.make_journals()
        hw.journal_headers.each do |jh|
          validate_journal(jh)
        end
        hw.save!
      end
    
      flash[:notice] = '家事按分仕訳を作成しました。'
    rescue => e
      handle(e)
    end
      
    redirect_to :action=>:index
  end
end
