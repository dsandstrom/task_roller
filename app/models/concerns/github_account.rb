# frozen_string_literal: true

class GithubAccount
  include ActiveModel::AttributeMethods
  include ActiveModel::Validations

  attr_accessor :remote_id, :username, :user

  def initialize(user)
    self.user = user
    self.remote_id = user.github_id
    self.username = user.github_username
  end

  validates :user, presence: true
  validates :remote_id, presence: true
  validates :username, presence: true

  def user_id
    @user_id ||= user&.id
  end

  def save
    user.update(github_id: remote_id, github_username: username)
  end

  def destroy
    self.remote_id = nil
    self.username = nil
    save
  end
end
