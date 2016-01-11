class CreateLineHashes < ActiveRecord::Migration
  def change
    create_table :line_hashes do |t|
      t.string :line
      t.string :letters
      t.integer :letters_hash
      t.integer :length

      t.timestamps null: false
    end
  end
end
