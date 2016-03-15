class Receipt < ActiveRecord::Base
  belongs_to :journal_header, :inverse_of => 'receipt'

  mount_uploader :file, ReceiptUploader
end
