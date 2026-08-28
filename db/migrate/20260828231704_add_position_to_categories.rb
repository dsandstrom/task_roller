class AddPositionToCategories < ActiveRecord::Migration[8.1]
  def change
    add_column :categories, :position, :integer

    Category.order(:id).each.with_index(1) do |category, index|
      category.update_column :position, index
    end
  end
end
