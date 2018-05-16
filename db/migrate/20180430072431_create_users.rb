class CreateUsers < ActiveRecord::Migration
  def change
        create_table :users do |t|
        t.string :name
        t.integer :university_id
        t.integer :grade
        t.string :sex
        t.string :mail
        t.string :password_digest
        t.string :line_id
        t.integer :point, :default => 50
        t.timestamps null: false
      end
  end
end