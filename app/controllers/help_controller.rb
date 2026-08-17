class HelpController < ApplicationController
  skip_authorization_check

  def index; end

  def issue_types; end

  def user_types; end

  def workflows; end
end
