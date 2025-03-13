require 'net/http'
require 'uri'
require 'json'

class Mm::SimpleSlipTemplatesController < Base::HyaccController

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
        @simple_slip_template.update!(simple_slip_template_params)
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
    appid = "#{Rails.application.secrets.yahoo_api_app_id}"
    url = "https://jlp.yahooapis.jp/FuriganaService/V2/furigana"
    remarks = params[:remarks]

    headers = {
      "Content-Type" => "application/json",
      "User-Agent" => "Yahoo AppID: " + appid,
    }

    param_dic = {
      "id": "1234-1",
      "jsonrpc": "2.0",
      "method": "jlp.furiganaservice.furigana",
      "params": {
        "q": remarks,
        "grade": 1
      }
    }

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    response = http.post(uri.path, param_dic.to_json, headers)
    response_body = JSON.parse(response.body).deep_symbolize_keys
    keywords = ''
    elements = response_body.dig(:result, :word)
    if elements
      elements.each do |elem|
        surface = elem[:surface]
        furigana = elem[:furigana]
        roman = elem[:roman]
        next if surface == '代' || surface == '料'
        if furigana.present?
          keywords << " " << surface << " " + furigana << " " << roman if furigana.size > 1
        else
          keywords << " " << surface if surface.size > 1
        end
      end
    end

    if HyaccLogger.debug?
      HyaccLogger.debug "\n  url=#{uri.host}\n  remarks=#{remarks}\n  keywords=#{keywords}"
    end
    
    render plain: keywords.strip
  end
  
  def get_sub_accounts
    account = Account.find(params[:account_id])
    @sub_accounts = account.sub_accounts.sort{|a, b| a.code <=> b.code }
    render :partial => 'get_sub_accounts', :locals => {:sub_accounts => @sub_accounts}
  end

  private

  def finder
    @finder ||= SimpleSlipTemplateFinder.new(finder_params)
    @finder.company_id = current_company.id
    @finder.page = params[:page] || 1
    @finder.per_page = current_user.slips_per_page
    @finder
  end
  
  def finder_params
    if params[:finder]
      ret = params.require(:finder).permit(
          :remarks, :account_id, :sub_account_id
        )
    end
  end

  def simple_slip_template_params
    params.require(:simple_slip_template).permit(
        :remarks, :owner_type, :owner_id, :description, :keywords,
        :account_id, :branch_id, :sub_account_id, :dc_type, :amount, :tax_type, :tax_rate_percent, :tax_amount, :focus_on_complete)
  end

end
