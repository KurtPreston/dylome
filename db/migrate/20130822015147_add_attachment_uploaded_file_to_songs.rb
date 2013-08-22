class AddAttachmentUploadedFileToSongs < ActiveRecord::Migration
  def self.up
    change_table :songs do |t|
      t.attachment :uploaded_file
    end
  end

  def self.down
    drop_attached_file :songs, :uploaded_file
  end
end
