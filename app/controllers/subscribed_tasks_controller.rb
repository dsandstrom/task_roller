# frozen_string_literal: true

class SubscribedTasksController < ApplicationController
  load_and_authorize_resource :subscribed_task, through: :current_user,
                                                class: 'Task'

  def index
    @subscribed_tasks =
      @subscribed_tasks.filter_by(build_filters).page(params[:page])
  end
end
