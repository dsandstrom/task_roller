class ConvertIssuesStatusToPending < ActiveRecord::Migration[8.1]
  def up
    Issue.where(status: 'open').update_all(status: 'pending')
  end

  def down
    Issue.where(status: 'pending').update_all(status: 'open')
  end
end
