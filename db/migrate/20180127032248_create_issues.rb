class CreateIssues < ActiveRecord::Migration[5.1]
  def change
    create_table :issues do |t|
      t.string :summary
      t.text :description
      t.integer :issue_type_id
      t.integer :user_id
      t.integer :project_id

      t.timestamps
    end

    add_index :issues, :issue_type_id
    add_index :issues, :user_id
    add_index :issues, :project_id
  end
end
