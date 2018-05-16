class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.integer :user_id
      t.integer :lesson_id
      t.integer :university_id
      t.string :title
      t.string :body
      t.string :img
      t.integer :point, :default => 0
      t.integer :request_id
      t.integer :request, :default => 0
      t.timestamps null: false
    end
  end
end
