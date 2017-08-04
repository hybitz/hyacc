class ReceiptUploader < Daddy::Uploader::Base
  storage :file
  process :set_metadata

  def store_dir
    File.join(model.class.table_name, model.journal_header_id.to_s)
  end

  def filename
    @_filename ||= HyaccUtil.hashed_filename(file.path)
  end

  private

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
