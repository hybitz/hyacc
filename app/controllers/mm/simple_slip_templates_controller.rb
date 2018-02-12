require 'net/http'
require "rexml/document"

class Mm::SimpleSlipTemplatesController < Base::HyaccController
  view_attribute :title => '簡易入力テンプレート'
  view_attribute :branches
  view_attribute :accounts

  helper_method :finder

  def index
    @templates = finder.list
  end

  def new
    @simple_slip_template = SimpleSlipTemplate.new
    @simple_slip_template.owner_type = OWNER_TYPE_COMPANY
    @simple_slip_template.owner_id = current_company.id
  end

  def create
    @simple_slip_template = SimpleSlipTemplate.new(simple_slip_template_params)

    begin
      @simple_slip_template.transaction do
        @simple_slip_template.save!
      end

      flash[:notice] = 'テンプレートを登録しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      render :new
    end
  end

  def edit
    @simple_slip_template = SimpleSlipTemplate.find(params[:id])
  end

  def update
    @simple_slip_template = SimpleSlipTemplate.find(params[:id])

    begin
      @simple_slip_template.transaction do
        @simple_slip_template.update_attributes!(simple_slip_template_params)
      end

      flash[:notice] = 'テンプレートを更新しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      render :edit
    end
  end

  def destroy
    @simple_slip_template = SimpleSlipTemplate.find(params[:id])

    begin
      SimpleSlipTemplate.transaction do
        @simple_slip_template.deleted = true
        @simple_slip_template.save!
      end

      flash[:notice] = 'テンプレートを削除しました。'
    rescue Exception => e
      handle(e)
    end

    redirect_to :action=>:index
  end
  
  def get_keywords
    url = 'jlp.yahooapis.jp'
    query = "/FuriganaService/V1/furigana?appid=#{current_user.yahoo_api_app_id}&sentence=#{params[:remarks]}"
    
    keywords = ''
    Net::HTTP.version_1_2
    Net::HTTP.start(url) do |http|
      response = http.get(query)
      xml = REXML::Document.new response.body

      elements = xml.elements['/ResultSet/Result/WordList']
      if elements.present?
        elements.each do |elem|
          next unless elem.class == REXML::Element
  
          surface = elem.elements['Surface'].text
          furigana = elem.elements['Furigana'].text
          roman = elem.elements['Roman'].text
          
          next if surface == furigana
          next if furigana.size <= 1
  
          keywords << " " << surface << " " + furigana << " " << roman
        end
      end
      
      if HyaccLogger.debug?
        HyaccLogger.debug "\n  url=#{url}\n  query=#{query}\n  keywords=#{keywords}"
      end
    end

    render :plain => keywords.strip
  end
  
  def get_sub_accounts
    account = Account.find(params[:account_id])
    @sub_accounts = account.sub_accounts.sort{|a, b| a.code <=> b.code }
    render :partial => 'get_sub_accounts', :locals => {:sub_accounts => @sub_accounts}
  end

  private

  def finder
    @finder ||= SimpleSlipTemplateFinder.new(finder_params)
    @finder.page = params[:page] || 1
    @finder.per_page = current_user.slips_per_page
    @finder
  end
  
  def finder_params
    if params[:finder]
      params.require(:finder).permit(
          :remarks, :account_id, :sub_account_id
        )
    end
  end

  def simple_slip_template_params
    params.require(:simple_slip_template).permit(
        :remarks, :owner_type, :owner_id, :description, :keywords,
        :account_id, :branch_id, :sub_account_id, :dc_type, :amount, :tax_type, :tax_amount, :focus_on_complete)
  end

end
