class ReceiptUploader < CarrierWave::Uploader::Base
  storage :file
  process :set_metadata

  def store_dir
    File.join(base_dir, model.class.table_name, model.journal_header_id.to_s)
  end

  def cache_dir
    File.join(base_dir, 'cache')
  end

  def filename
    @_filename ||= HyaccUtil.hashed_filename(file.path)
  end

  private

  def base_dir
    if Rails.env.test?
      "/tmp/hyacc/#{Rails.env}"
    else
      "/var/lib/hyacc/#{Rails.env}"
    end
  end

  def set_metadata
    if model.present?
      if file.is_a?(File)
        model.original_filename = File.basename(file)
      else
        model.original_filename = file.original_filename 
      end
      model.deleted = false
    end
  end
end
