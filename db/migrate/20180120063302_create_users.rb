class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.integer :employee_id

      t.timestamps
    end

    add_index :users, :email
    add_index :users, :employee_id
  end
end
