class RepositionCategoriesController < ApplicationController
  load_and_authorize_resource class: 'Category', instance_name: :category,
                              only: :update

  def index
    authorize! :update, Category

    @categories = Category.accessible_by(current_ability)
                          .order('categories.position asc').preload(:projects)
  end

  def update
    @category.new_position = category_params[:new_position].to_i

    if @category.valid? && @category.reposition
      update_success
    else
      update_failure
    end
  end

  private

    def category_params
      params.expect(category: %i[new_position])
    end

    def update_success
      respond_to do |format|
        format.html do
          redirect_to reposition_categories_path,
                      notice: "#{@category.name} was successfully moved "
        end
        format.json { head :ok }
      end
    end

    def update_failure
      respond_to do |format|
        format.html do
          redirect_to reposition_categories_path,
                      notice: "#{@category.name} was unable to be moved "
        end
        format.json { head :unprocessable_content }
      end
    end
end
