module Base
  class BasicMasterController < HyaccController
    
    def index
      if params[:finder].present?
        @finder = finder_class.new(params[:finder])
      else
        @finder = session[finder_class.name] || finder_class.new
      end

      if params[:commit]
        @list = @finder.list
      end

      respond_to do |format|
        format.html
        format.xml  { render :xml => @list }
      end
    end
    
    def show
      @data = model_class.find(params[:id])
      respond_to do |format|
        format.html {render :partial=>'line', :locals => {:data => @data}}
        format.xml  {render :xml => @data }
        format.js   {render :show}
      end
    end
    
    def new
      @data = model_class.new

      respond_to do |format|
        format.html
        format.xml  { render :xml => @data }
      end
    end

    def create
      @data = model_class.new(eval(param_name))
      respond_to do |format|
        begin
          @data.save!
          flash[:notice] = '登録に成功しました。'
          format.html { redirect_to :action => 'index' }
          format.xml  { render :xml => @data, :status => :created, :location => @data }
        rescue => e
          handle(e)
          format.html { redirect_to :action => 'index', :commit=>''}
          format.xml  { render :xml => @data.errors, :status => :unprocessable_content }
        end
      end
    end
    
    def edit
      @data = model_class.find(params[:id])
      respond_to do |format|
        format.html do
          render :partial => 'form'
        end
        format.js do
          render :edit
        end
      end
    end

    def update
      @data = model_class.find(params[:id])

      respond_to do |format|
        if @data.update(eval(param_name))
          format.html { render partial: 'line', locals: {data: @data} }
          format.xml  { head :ok }
          format.js   { render :show }
        else
          format.html { render partial: "form" }
          format.xml  { render xml: @data.errors, :status => :unprocessable_content }
          format.js   { render js: "alert('#{@data.errors.full_messages.join('\n')}');" }
        end
      end
    end
    
    def upload
      @list = []
      line_count = 0
      file = params[:file]
      begin
        model_class.transaction do
          CSV.parse(file.tempfile) do |row|
            # コメント（#）行をスキップ
            next if row.to_a[0].slice(0, 1) == "#"
            data = model_class.new_by_array(make_array(row.to_a))
            unless data != nil and data.save
              raise HyaccException.new("登録に失敗しました。：" + (line_count + 1).to_s + "件目")
            end
            @list << data
            line_count += 1
          end

          flash[:notice] = "#{line_count}件のデータが登録されました"
          redirect_to :action => 'index'
        end
      rescue => e
        handle(e)
        redirect_to :action => 'new'
      end
    end
    
    def destroy
      data = model_class.find(params[:id])
      data.destroy

      respond_to do |format|
        format.html { redirect_to :action => 'index' }
        format.xml  { head :ok }
      end
    end

    protected

    def make_array(csv_array)
      # デフォルトはCSVをそのままモデルにセット
      csv_array
    end

    private

    def model_class
      @model_class ||= controller_name.singularize.classify.constantize
    end

    def finder_class
      @finder_class ||= (controller_name.singularize.classify + 'Finder').constantize
    end

    def param_name
      model_class.name.underscore + '_params'
    end

  end
end
