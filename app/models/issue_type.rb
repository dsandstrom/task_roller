class IssueType < ApplicationRecord
  ICON_OPTIONS = IconFileReader.new.options.freeze
  COLOR_OPTIONS = %w[default blue brown green purple red yellow].freeze

  acts_as_list
  default_scope { order(position: :asc) }

  attr_accessor :new_position

  has_many :search_results, dependent: nil

  validates :icon, presence: true, inclusion: { in: ICON_OPTIONS }
  validates :name, presence: true, length: { maximum: 100 },
                   uniqueness: { case_sensitive: false }
  validates :color, presence: true, inclusion: { in: COLOR_OPTIONS }
  validate :new_position_numericality

  def reposition
    return false if new_position.blank?

    insert_at(new_position) || false
  rescue ArgumentError => e
    logger.debug "ArgumentError: #{e}"
    false
  end

  def any_issues?
    Issue.where(issue_type: self).any?
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

      max_position = IssueType.count
      return unless max_position && new_position > max_position

      errors.add(:new_position, "must less than #{max_position + 1}")
    end
end
