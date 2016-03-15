class UpdateReceipts < ActiveRecord::Migration
  def up
    Journal.where('receipt_path is not null').find_each(:batch_size => 100) do |j|
      next if j.receipt.present?
      next if j.receipt_path.blank?
      next unless File.exist?(j.receipt_path)

      puts "#{j.id}: #{j.receipt_path}"
      r = j.build_receipt(:file => File.new(File.join(UPLOAD_DIRECTORY, j.receipt_path)))
      r.save!
    end
  end

  def down
  end
end
