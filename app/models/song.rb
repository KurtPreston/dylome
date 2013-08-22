class Song < ActiveRecord::Base
  has_attached_file :uploaded_file
  validates_attachment :uploaded_file,  presence: true

  has_attached_file :processed_file

  validates_presence_of :name
end
