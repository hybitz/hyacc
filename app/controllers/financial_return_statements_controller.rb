class FinancialReturnStatementsController < Base::HyaccController
  view_attribute :finder, class: ReportFinder
  view_attribute :branches
  view_attribute :report_types

  def index
    if finder.commit
      logic = "Reports::#{finder.report_type.camelize}Logic".constantize.new(finder)
      @model = logic.build_model

      template_dir = File.join(Rails.root, 'app', 'views', 'financial_return_statements', finder.report_type) 
      if Dir.exist? template_dir
        template = nil
        Dir[File.join(template_dir, '*.html.erb')].sort.reverse.each do |t|
          ymd = File.basename(t).split('.').first
          next if ymd > logic.end_ymd
          template = ymd
          break
        end
        render "financial_return_statements/#{finder.report_type}/#{template}"
      else
        render finder.report_type
      end
    end
  end

end
