class ReportController < Base::HyaccController
  view_attribute :title => '帳票出力'

  def index
  end

  class Base < Base::HyaccController
    layout 'report'
  end
end
