class StaticController < ApplicationController
  skip_authorization_check

  def unauthorized; end

  def sitemap
    @categories = Category.accessible_by(current_ability)
                          .order(:position).preload(:projects)
  end
end
