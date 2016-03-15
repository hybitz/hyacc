class ReceiptsController < ApplicationController

  def show
    @receipt = Receipt.find(params[:id])
    send_file @receipt.file.path, :filename => @receipt.original_filename
  end

end
