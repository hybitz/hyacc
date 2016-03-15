class UpdateReceipts < ActiveRecord::Migration
  def up
    Journal.where('receipt_path is not null').find_each(:batch_size => 100) do |j|
      next if j.receipt.present?
      next if j.receipt_path.blank?
      
      path = File.join(UPLOAD_DIRECTORY, j.receipt_path)
      next unless File.exist?(path)

      puts "#{j.id}: #{path}"
      r = j.build_receipt(:file => File.new(path))
      r.save!
    end
  end

  def down
  end
end
