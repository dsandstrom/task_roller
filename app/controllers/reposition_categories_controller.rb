class RepositionCategoriesController < ApplicationController
  load_and_authorize_resource class: 'Category', instance_name: :category,
                              only: :update

  def index
    authorize! :update, Category

    @categories = Category.accessible_by(current_ability)
                          .order('categories.position asc').preload(:projects)
  end

  def update
    if @category.valid? && @category.reposition(params[:sort])
      redirect_to reposition_categories_path,
                  notice: "#{@category.name} was successfully moved " \
                          "#{params[:sort]}."
    else
      redirect_to reposition_categories_path,
                  notice: 'Category was unable to be moved.'
    end
  end
end
