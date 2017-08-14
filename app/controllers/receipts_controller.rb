class ReceiptsController < ApplicationController

  def show
    @receipt = Receipt.find(params[:id])

    send_data @receipt.file.read,
        :filename => @receipt.original_filename,
        :type => MimeMagic.by_path(@receipt.original_filename),
        :disposition => 'attachment'
  end

end
