class Receipt < ApplicationRecord
  belongs_to :journal, :inverse_of => 'receipt'

  mount_uploader :file, ReceiptUploader
end
