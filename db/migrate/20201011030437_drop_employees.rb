# frozen_string_literal: true

class DropEmployees < ActiveRecord::Migration[6.0]
  def change
    remove_index :employees, :type

    drop_table :employees do
      t.string :type
      t.timestamps
    end
  end
end
