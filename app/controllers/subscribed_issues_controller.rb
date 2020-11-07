# frozen_string_literal: true

class SubscribedIssuesController < ApplicationController
  load_and_authorize_resource :subscribed_issue, through: :current_user,
                                                 class: 'Issue'

  def index
    @subscribed_issues =
      @subscribed_issues.filter_by(build_filters).page(params[:page])
  end
end
