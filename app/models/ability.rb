# frozen_string_literal: true

# See the wiki for details:
# https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

class Ability
  include CanCan::Ability

  EXTERNAL_CATEGORY_OPTIONS = { visible: true, internal: false }.freeze
  EXTERNAL_PROJECT_OPTIONS = { visible: true, internal: false,
                               category: EXTERNAL_CATEGORY_OPTIONS }.freeze
  VISIBLE_CATEGORY_OPTIONS = { visible: true }.freeze
  VISIBLE_PROJECT_OPTIONS = { visible: true,
                              category: VISIBLE_CATEGORY_OPTIONS }.freeze
  VISIBLE_OPTIONS = { project: { visible: true,
                                 category: VISIBLE_CATEGORY_OPTIONS } }.freeze
  EXTERNAL_OPTIONS = { project: { visible: true, internal: false,
                                  category: EXTERNAL_CATEGORY_OPTIONS } }.freeze

  def initialize(user)
    can :create, User, employee_type: 'Reporter' if User.allow_registration?
    return unless user && user.employee_type.present?

    [CategoryAbility, ProjectAbility, UserAbility, IssueAbility,
     TaskAbility, SearchResultAbility].each do |klass|
      ability = klass.new(ability: self, user: user)
      ability.activate
    end
  end
end
