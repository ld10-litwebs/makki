class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.integer :university_id
      t.string :lesson
      t.timestamps null: false
    end
  end
end
