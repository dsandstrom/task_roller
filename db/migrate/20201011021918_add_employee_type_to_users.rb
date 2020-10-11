# frozen_string_literal: true

class AddEmployeeTypeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :employee_type, :string
    remove_column :users, :employee_id, :integer
  end
end
