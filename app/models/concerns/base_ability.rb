# frozen_string_literal: true

class BaseAbility
  attr_accessor :ability, :user

  def initialize(attrs)
    %i[ability user].each do |key|
      send("#{key}=", attrs[key])
    end
  end

  def user_id
    @user_id ||= user&.id
  end
end
