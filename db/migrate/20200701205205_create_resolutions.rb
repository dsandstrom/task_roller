class CreateResolutions < ActiveRecord::Migration[6.0]
  def change
    create_table :resolutions do |t|
      t.integer :issue_id, null: false
      t.integer :user_id, null: false
      t.boolean :approved

      t.timestamps
    end
  end
end
