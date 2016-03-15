require 'digest/md5'

class ReceiptUploader < CarrierWave::Uploader::Base
  storage :file
  process :set_metadata

  def store_dir
    "/var/lib/hyacc/#{Rails.env}/#{model.class.table_name}/#{model.journal_header_id}"
  end

  def cache_dir
    "/var/lib/hyacc/#{Rails.env}/tmp/cache"
  end

  def filename
    if model.file?
      @_filename ||= "#{Digest::MD5.file(file.path)}#{File.extname(file.path)}"
    else
      super
    end
  end

  private

  def set_metadata
    if model.file?
      if file.is_a?(File)
        model.original_filename = File.basename(file)
      else
        model.original_filename = file.original_filename 
      end
      model.deleted = false
    end
  end
end
