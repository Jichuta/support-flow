class CreateSupportRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :support_requests do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.integer :status, null: false, default: 0
      t.integer :priority, null: false, default: 1
      t.date :due_date
      t.datetime :resolved_at
      t.references :creator, null: false, foreign_key: { to_table: :team_members }
      t.references :assignee, foreign_key: { to_table: :team_members }
      t.references :team, null: false, foreign_key: { to_table: :team_members }

      t.timestamps
    end

    add_index :support_requests, :status
    add_index :support_requests, :priority
    add_index :support_requests, :due_date
  end
end