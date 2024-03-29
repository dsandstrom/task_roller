# frozen_string_literal: true

class User < ApplicationRecord # rubocop:disable Metrics/ClassLength
  # Include default devise modules. Others available are:
  #    :timeoutable
  devise :confirmable, :database_authenticatable, :lockable, :recoverable,
         :registerable, :rememberable, :trackable, :validatable, :omniauthable,
         omniauth_providers: %i[github]
  VALID_EMPLOYEE_TYPES = %w[Admin Reviewer Worker Reporter].freeze
  ASSIGNABLE_EMPLOYEE_TYPES = %w[Reviewer Worker].freeze

  has_many :task_assignees, foreign_key: :assignee_id, inverse_of: :assignee,
                            dependent: :destroy
  has_many :assignments, through: :task_assignees, class_name: 'Task',
                         source: :task
  has_many :progressions, dependent: :destroy
  has_many :issues, dependent: :nullify
  has_many :tasks, dependent: :nullify
  has_many :issue_comments, dependent: :nullify
  has_many :task_comments, dependent: :nullify
  has_many :reviews, dependent: :nullify
  has_many :issue_subscriptions, dependent: :destroy
  has_many :subscribed_issues, through: :issue_subscriptions, source: :issue
  has_many :task_subscriptions, dependent: :destroy
  has_many :subscribed_tasks, through: :task_subscriptions, source: :task
  has_many :category_issues_subscriptions, dependent: :destroy
  has_many :category_tasks_subscriptions, dependent: :destroy
  has_many :subscribed_issue_categories,
           through: :category_issues_subscriptions,
           source: :category
  has_many :subscribed_task_categories,
           through: :category_tasks_subscriptions,
           source: :category
  has_many :project_issues_subscriptions, dependent: :destroy
  has_many :project_tasks_subscriptions, dependent: :destroy
  has_many :issue_closures, dependent: :nullify
  has_many :task_closures, dependent: :nullify
  has_many :issue_reopenings, dependent: :nullify
  has_many :task_reopenings, dependent: :nullify
  has_many :issue_notifications, dependent: :destroy
  has_many :task_notifications, dependent: :destroy
  has_many :notifying_tasks, through: :task_notifications, class_name: 'Task',
                             source: :task
  has_many :notifying_issues, through: :issue_notifications,
                              class_name: 'Issue', source: :issue
  has_many :repo_callouts, dependent: :nullify

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :employee_type, inclusion: { in: VALID_EMPLOYEE_TYPES },
                            allow_nil: false, on: :create
  validates :employee_type, inclusion: { in: VALID_EMPLOYEE_TYPES },
                            allow_nil: true, on: :update
  validates :github_id, uniqueness: true, allow_nil: true

  # CLASS

  def self.employees(type = nil)
    if type.blank?
      where(employee_type: VALID_EMPLOYEE_TYPES)
    elsif type.instance_of?(Array)
      return none unless type.all? { |t| VALID_EMPLOYEE_TYPES.include?(t) }

      where(employee_type: type)
    else
      return none unless VALID_EMPLOYEE_TYPES.include?(type)

      where(employee_type: type)
    end
  end

  def self.admins
    where(employee_type: 'Admin')
  end

  def self.reporters
    where(employee_type: 'Reporter')
  end

  def self.reviewers
    where(employee_type: 'Reviewer')
  end

  def self.workers
    where(employee_type: 'Worker')
  end

  def self.unemployed
    where('employee_type IS NULL OR employee_type NOT IN (?)',
          VALID_EMPLOYEE_TYPES)
  end

  # used in task filter form to display unassigned tasks
  def self.unassigned
    new(id: 0, name: '~ Unassigned ~')
  end

  def self.assignable_employees
    employees(ASSIGNABLE_EMPLOYEE_TYPES)
  end

  def self.destroyed_name
    'removed'
  end

  # users from progressions that aren't current assignees
  def self.assigned_to(task)
    query = 'task_assignees.task_id = :id OR progressions.task_id = :id'
    order = 'progressions.created_at asc, task_assignees.created_at asc'

    assigned = eager_load(:progressions, :task_assignees)
               .where(query, id: task.id)
    if task.open? && task.assignee_ids.any?
      assigned = assigned.where.not(users: { id: task.assignee_ids })
    end
    assigned.order(order)
  end

  # Whether to allow guests to sign up
  def self.allow_registration?
    ENV['USER_REGISTRATION'] == 'enabled'
  end

  # https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview
  # This method tries to find an existing user by the provider and uid fields.
  # If no user is found, a new one is created with a random password and some
  # extra information. Note that the first_or_create method automatically sets
  # the provider and uid fields when creating a new user. The first_or_create!
  # method operates similarly, except that it will raise an Exception if the
  # user record fails validation.
  def self.from_omniauth(auth)
    return unless auth.uid.present? && auth.info

    where(github_id: auth.uid).first_or_create do |user|
      attrs = { github_username: auth.info.nickname, email: auth.info.email,
                employee_type: 'Reporter', name: auth.info.name }
      user.assign_attributes(attrs)
      # user.image = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate
      # emails, uncomment the line below to skip the confirmation emails.
      # sets confirmed_at
      user.skip_confirmation!
    end
  end

  # https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview
  # Notice that Devise's RegistrationsController by default calls
  # User.new_with_session before building a resource. This means that, if we
  # need to copy data from session whenever a user is initialized before sign
  # up, we just need to implement new_with_session in our model. Here is an
  # example that copies the facebook email if available:
  # TODO: set confirmed_at?
  def self.new_with_session(params, session)
    super.tap do |user|
      data = session['devise.github_data']
      if data
        next if user.email.present?

        user.email = data['email']
      end
    end
  end

  # INSTANCE

  def add_omniauth(auth)
    return false unless auth.uid.present? && auth.info
    return false unless confirmed?

    attrs = { github_id: auth.uid, github_username: auth.info.nickname }
    update(attrs)
  end

  def admin?
    @admin_ = employee_type == 'Admin' if @admin_.nil?
    @admin_
  end

  def reviewer?
    @reviewer_ = employee_type == 'Reviewer' if @reviewer_.nil?
    @reviewer_
  end

  def worker?
    @worker_ = employee_type == 'Worker' if @worker_.nil?
    @worker_
  end

  def reporter?
    @reporter_ = employee_type == 'Reporter' if @reporter_.nil?
    @reporter_
  end

  def employee?
    if @employee_.nil?
      @employee_ = employee_type.present? &&
                   VALID_EMPLOYEE_TYPES.include?(employee_type)
    end
    @employee_
  end

  def name_and_email
    @name_and_email ||=
      if name && email
        "#{name} (#{email})"
      elsif name
        name
      else
        email
      end
  end

  def name_or_email
    @name_or_email ||= (name || email)
  end

  def task_progressions(task)
    progressions.where(task_id: task.id).order(created_at: :asc)
  end

  # group up progression dates to make something readable
  # TODO: "3/5-3/6, 3/7-3/8" -> "3/5-3/8"
  # TODO: "3/6, 3/6-3/8" -> "3/6-3/8"
  # TODO: finished only? ("3/6-")
  def task_progress(task)
    task_progressions(task).map do |progression|
      start_date = progression.start_date
      finish_date = progression.finish_date

      if start_date == finish_date
        start_date
      else
        "#{start_date}-#{finish_date}"
      end
    end.uniq.join(', ')
  end

  # used by Task#finish_progressions
  def finish_progressions
    progressions.unfinished.each(&:finish)
  end

  # order by:
  # task has open progression by user
  # task has progressions by user
  # no progressions or reviews
  # pending review
  # comment by another user
  ACTIVE_ASSIGNMENTS_QUERY =
    'tasks.*, ' \
    'SUM(case when progressions.finished IS FALSE then 1 else 0 end) ' \
    'AS unfinished_progressions_count, ' \
    'COUNT(progressions.id) AS progressions_count, ' \
    'SUM(case when reviews.id IS NOT NULL AND reviews.approved IS NULL ' \
    'then 1 else 0 end) AS pending_reviews_count, ' \
    'COALESCE(MAX(task_comments.created_at), MAX(progressions.created_at), ' \
    'tasks.created_at) AS order_date'
  ACTIVE_ASSIGNMENTS_ORDER =
    { unfinished_progressions_count: :desc, pending_reviews_count: :asc,
      progressions_count: :desc, order_date: :desc }.freeze
  def active_assignments
    comments_query =
      'LEFT OUTER JOIN task_comments ON ' \
      "(tasks.id = task_comments.task_id AND task_comments.user_id != #{id})"
    @active_assignments ||=
      assignments
      .left_joins(:progressions, :reviews).joins(comments_query)
      .all_non_closed.select(ACTIVE_ASSIGNMENTS_QUERY)
      .group(:id).order(ACTIVE_ASSIGNMENTS_ORDER)
  end

  # TODO: add recently addressed issues?
  # for reporters/show view
  # link to user/issues which will be filterable
  UNRESOLVED_ISSUES_ORDER =
    { open_tasks_count: :desc, tasks_count: :desc, order_date: :desc }.freeze
  UNRESOLVED_ISSUES_QUERY =
    'issues.*, ' \
    'COALESCE(MAX(issue_comments.created_at), issues.created_at) AS order_date'
  def unresolved_issues
    @unresolved_issues ||=
      issues
      .all_non_closed.left_joins(:comments).references(:comments)
      .select(UNRESOLVED_ISSUES_QUERY)
      .where('issue_comments.id IS NULL OR issue_comments.user_id != ?', id)
      .group(:id).order(UNRESOLVED_ISSUES_ORDER)
  end

  # priority:
  # in review
  # in progress
  # assigned
  # open
  #
  # order:
  # comment by another user, progression, created_at
  OPEN_TASKS_QUERY =
    'tasks.*, ' \
    'COUNT(progressions.id) AS progressions_count, ' \
    'SUM(case when reviews.id IS NOT NULL AND reviews.approved IS NULL ' \
    'then 1 else 0 end) AS pending_reviews_count, ' \
    'COALESCE(MAX(task_comments.created_at), MAX(progressions.created_at), ' \
    'tasks.created_at) AS order_date'
  OPENS_TASKS_ORDER =
    { pending_reviews_count: :desc, progressions_count: :desc,
      order_date: :desc }.freeze
  def open_tasks
    @open_tasks ||=
      tasks
      .all_non_closed.select(OPEN_TASKS_QUERY)
      .left_joins(:progressions, :reviews, :comments).references(:comments)
      .where('task_comments.id IS NULL OR task_comments.user_id != ?', id)
      .group(:id).order(OPENS_TASKS_ORDER)
  end

  def subscriptions
    query = 'issue_subscriptions.id IS NOT NULL OR '\
            'task_subscriptions.id IS NOT NULL'
    SearchResult.joins(issue_subscriptions_query)
                .joins(task_subscriptions_query)
                .where(query)
  end

  def subscribed_issues_with_notifications(order_by: false)
    query = 'LEFT OUTER JOIN issue_notifications ON '\
            '(issue_notifications.issue_id = issues.id AND '\
            "issue_notifications.user_id = #{id})"
    issues = subscribed_issues.joins(query).select('issues.*').group(:id)
                              .preload(:project, :user, project: :category)
    return issues unless order_by

    issues.order('COUNT(issue_notifications.id) DESC')
  end

  def subscribed_tasks_with_notifications(order_by: false)
    query = 'LEFT OUTER JOIN task_notifications ON '\
            '(task_notifications.task_id = tasks.id AND '\
            "task_notifications.user_id = #{id})"
    tasks = subscribed_tasks.joins(query).select('tasks.*').group(:id)
                            .preload(:project, :user, :issue, :assignees,
                                     project: :category)
    return tasks unless order_by

    tasks.order('COUNT(task_notifications.id) DESC')
  end

  def subscriptions_with_notifications(order_by: false)
    attrs = %w[id project_id user_id issue_id class_name created_at updated_at
               summary description status type_id]
    search_results =
      subscriptions.joins(notifications_query)
                   .select(attrs).group(attrs)
                   .preload(:project, :user, :issue, :assignees,
                            project: :category)
    return search_results unless order_by

    search_results.order('COUNT(issue_notifications.id) DESC')
                  .order('COUNT(task_notifications.id) DESC')
  end

  # block non-employees from devise
  def active_for_authentication?
    super && employee?
  end

  def password?
    @password_ = encrypted_password.present? if @password_.nil?
    @password_
  end

  def notifications_query
    @notifications_query ||=
      'LEFT OUTER JOIN issue_notifications ON '\
      '(issue_notifications.issue_id = search_results.id AND '\
      "search_results.class_name = 'Issue' AND "\
      "issue_notifications.user_id = #{id}) "\
      'LEFT OUTER JOIN task_notifications ON '\
      '(task_notifications.task_id = search_results.id AND '\
      "search_results.class_name = 'Task' AND "\
      "task_notifications.user_id = #{id})"
  end

  def github_account
    @github_account ||= GithubAccount.new(self)
  end

  protected

    # https://github.com/heartcombo/devise/wiki/How-To:-Email-only-sign-up
    # override to be able to create without a password
    # or to allow sign in with github only
    def password_required?
      if @password_required_.nil?
        @password_required_ = github_id.present? || !confirmed? ? false : super
      end
      @password_required_
    end

  private

    def issue_subscriptions_query
      @issue_subscriptions_query ||=
        'LEFT OUTER JOIN issue_subscriptions ON '\
        '(issue_subscriptions.issue_id = search_results.id AND '\
        "search_results.class_name = 'Issue' AND "\
        "issue_subscriptions.user_id = #{id})"
    end

    def task_subscriptions_query
      @task_subscriptions_query ||=
        'LEFT OUTER JOIN task_subscriptions ON '\
        '(task_subscriptions.task_id = search_results.id AND '\
        "search_results.class_name = 'Task' AND "\
        "task_subscriptions.user_id = #{id})"
    end
end
