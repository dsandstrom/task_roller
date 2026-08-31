class AddPositionToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :position, :integer

    Category.all.each do |category|
      Project.where(category_id: category.id).order(:id)
             .each.with_index(1) do |project, index|
        project.update_column :position, index
      end
    end
  end
end
