module Report::WithholdingSlipHelper

  def year_end(calendar_year)
    calendar_year.to_s + '/12/31'
  end
  
  def detail_render(calendar_year)
    d = File.join(HyaccUtil.view_dir, controller_path)
    Dir.glob(File.join(d, '_details_*.html.erb')).each do |filename|
      valid_from, valid_until = filename_to_date(filename)
      if calendar_year.to_i.between?(valid_from, valid_until)
        basename = File.basename(filename).split('.').first
        basename.slice!(0)
        return basename
      end
    end
  end
  
  def filename_to_date(filename)
    valid_from, valid_until = File.basename(filename).split('.').first.split('_')[2, 2]
    valid_from = valid_from.to_i
    valid_until = valid_until.to_i
    [valid_from, valid_until]
  end
end
