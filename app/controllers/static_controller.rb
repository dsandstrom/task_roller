# frozen_string_literal: true

class StaticController < ApplicationController
  # TODO: remove or authorize dashboard
  skip_authorization_check

  def dashboard; end

  def unauthorized; end
end
