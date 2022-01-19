# frozen_string_literal: true

class StaticController < ApplicationController
  skip_authorization_check

  def unauthorized; end

  def sitemap
    @categories = Category.accessible_by(current_ability).preload(:projects)
  end
end
