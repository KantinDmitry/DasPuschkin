class CreateVerses < ActiveRecord::Migration
  def change
    create_table :verses do |t|
      t.string :title
      t.string :text

      t.timestamps null: false
    end
  end
end
