# frozen_string_literal: true

class HelpController < ApplicationController
  # TODO: if registration is open, allow guests to access?
  skip_authorization_check

  def index; end

  def issue_types; end

  def user_types; end

  def workflows; end
end
