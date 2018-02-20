class CreateGroupEvents < ActiveRecord::Migration
  def change
    create_table :group_events do |t|
      t.references :user
      t.string :name
      t.text :description
      t.date :start_at
      t.date :end_at
      t.integer :duration
      t.string :location
      t.integer :status, default: 1

      t.timestamps null: false
    end
  end
end
