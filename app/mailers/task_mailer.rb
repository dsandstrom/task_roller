# frozen_string_literal: true

class TaskMailer < ApplicationMailer
  attr_accessor :task, :user

  def new
    set_instance_variables

    options = { to: @user.email }
    options[:subject] = subject('New')

    mail(options)
  end

  def status
    set_instance_variables
    @old_status = params[:old_status]
    @new_status = params[:new_status]

    options = { to: @user.email }
    options[:subject] = subject('Update for')

    mail(options)
  end

  def comment
    set_instance_variables
    @comment = params[:comment]

    options = { to: @user.email }
    options[:subject] = subject('Comment for')

    mail(options)
  end

  private

    def set_instance_variables
      %i[task user].each do |attribute|
        send("#{attribute}=", params[attribute])
      end
    end

    def subject(prefix)
      "Task Roller: #{prefix} Task##{task.id}"
    end
end
