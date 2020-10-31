# frozen_string_literal: true

class StaticController < ApplicationController
  skip_authorization_check

  def dashboard; end

  def unauthorized; end
end
