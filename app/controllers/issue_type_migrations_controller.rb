class IssueTypeMigrationsController < ApplicationController
  load_and_authorize_resource :issue_type
  before_action :build_issue_type_options, only: :new

  def new; end

  def create
    @new_issue_type = IssueType.find(issue_type_params[:new_issue_type_id])
    # rubocop:disable Rails/SkipsModelValidations
    Issue.where(issue_type: @issue_type)
         .update_all(issue_type_id: @new_issue_type.id)
    # rubocop:enable Rails/SkipsModelValidations
    redirect_to issue_types_path, notice: notice
  rescue ActiveRecord::RecordNotFound
    build_issue_type_options
    @issue_type.errors.add(:new_issue_type_id, 'not found')
    render :new
  end

  private

    def issue_type_params
      params.expect(issue_type: %i[new_issue_type_id])
    end

    def build_issue_type_options
      @issue_types = IssueType.where.not(id: @issue_type.id)
    end

    def notice
      "'#{@issue_type.name}' issues where successfully migrated to " \
        "'#{@new_issue_type.name}' type"
    end
end
