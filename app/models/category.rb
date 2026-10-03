class Category < ApplicationRecord
  has_many :projects, dependent: :destroy
  has_many :issues, through: :projects
  has_many :tasks, through: :projects
  has_many :search_subscriptions, dependent: :destroy

  acts_as_list

  attr_accessor :new_position

  validates :name, presence: true, length: { maximum: 200 }
  validate :new_position_numericality

  # CLASS

  def self.all_visible
    where(visible: true).order(position: :asc)
  end

  def self.all_invisible
    where(visible: false).order(position: :asc)
  end

  def self.with_projects
    joins(:projects).order(:position)
  end

  # INSTANCE

  def name_and_tag
    @name_and_tag ||= build_name_and_tag
  end

  def reposition
    return false if new_position.blank?

    insert_at(new_position) || false
  rescue ArgumentError => e
    logger.debug "ArgumentError: #{e}"
    false
  end

  def projects_except(excluded_project = nil)
    return projects unless excluded_project

    projects.where.not(id: excluded_project.id)
  end

  private

    def new_position_numericality
      return if new_position.blank?

      unless new_position.instance_of?(Integer)
        return errors.add(:new_position, 'must be an integer')
      end

      unless new_position.positive?
        return errors.add(:new_position, 'must greater than 0')
      end

      max_position = Category.count
      return unless max_position && new_position > max_position

      errors.add(:new_position, "must less than #{max_position + 1}")
    end

    def build_name_and_tag
      tags = []

      tags << 'archived' unless visible?
      tags << 'internal' if internal?

      "#{name}#{" (#{tags.join(', ')})" if tags.any?}"
    end
end
