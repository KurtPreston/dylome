class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.string :name
      t.float :length
      t.float :bpm

      t.timestamps
    end
  end
end
