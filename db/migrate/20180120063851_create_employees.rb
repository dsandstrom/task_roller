class CreateEmployees < ActiveRecord::Migration[5.1]
  def change
    create_table :employees do |t|
      t.string :type

      t.timestamps
    end

    add_index :employees, :type
  end
end
