class CategoryMigrationsController < ApplicationController
  load_resource :category, except: :index
  before_action :authorize_migrate
  before_action :set_categories, only: :new

  def index
    @categories = Category.preload(:projects).order(:position)
  end

  def new; end

  def create
    @new_category = Category.find(category_params[:migration_id])
    # rubocop:disable Rails/SkipsModelValidations
    Project.where(category: @category)
           .update_all(category_id: @new_category.id)
    # rubocop:enable Rails/SkipsModelValidations
    redirect_to root_url, notice: notice
  rescue ActiveRecord::RecordNotFound
    set_categories
    @category.errors.add(:new_category_id, 'not found')
    render :new
  end

  private

    def authorize_migrate
      authorize! :migrate, (@category || Category)
    end

    def category_params
      params.expect(category: %i[migration_id])
    end

    def set_categories
      @categories = Category.where.not(id: @category.id).order(:position)
      return if @categories.any?

      raise ApplicationError::MissingCategories, 'Another category is required'
    end

    def notice
      "Issues and Tasks from '#{@category.name}' were successfully migrated " \
        "to '#{@new_category.name}'"
    end
end
