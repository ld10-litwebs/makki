class CreateUniversities < ActiveRecord::Migration
  def change
    create_table :universities do |t|
      t.string :university
      t.string :course
      t.timestamps null: false
    end
  end
end
