class RemoveTeamId < ActiveRecord::Migration[8.1]
  def change
    remove_column :support_requests, :team_id, :bigint
  end
end
