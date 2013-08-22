class AddAttachmentProcessedFileToSongs < ActiveRecord::Migration
  def self.up
    change_table :songs do |t|
      t.attachment :processed_file
    end
  end

  def self.down
    drop_attached_file :songs, :processed_file
  end
end
