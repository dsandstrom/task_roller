class AddRepoCalloutIdToProgressions < ActiveRecord::Migration[6.1]
  def change
    add_column :progressions, :repo_callout_id, :integer
    add_column :reviews, :repo_callout_id, :integer
  end
end
