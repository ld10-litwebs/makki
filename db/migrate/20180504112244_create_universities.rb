class CreateUniversities < ActiveRecord::Migration[5.0]
  def change
    create_table :universities do |t|
      t.string :university
      t.string :course
      t.timestamps null: false
    end
  end
end
