module Receipts

  def receipt
    if @_receipt.nil?
      @_receipt = Receipt.first
      @_receipt.file = File.new(File.join('test/data', @_receipt.original_filename))
      assert @_receipt.save
    end
    
    @_receipt
  end

end