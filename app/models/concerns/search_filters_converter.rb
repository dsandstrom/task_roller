class SearchFiltersConverter
  ATTRS_TO_PARAMS_MAP =
    { term: :query, issue_status: :issue_status, task_status: :task_status,
      issue_type_id: :issue_type_id, task_type_id: :task_type_id,
      project_id: :project_id, category_id: :category_id,
      source_user_id: :user_id }.freeze

  DEFAULT_ATTRS =
    { include_issues: true, include_tasks: true, term: nil,
      issue_type_id: nil, task_type_id: nil, issue_status: nil,
      task_status: nil, category_id: nil, project_id: nil,
      source_user_id: nil }.freeze

  DEFAULT_ISSUE_PARAMS =
    { type: 'issues', issue_status: 'all', issue_type_id: 'all' }.freeze

  DEFAULT_TASK_PARAMS =
    { type: 'tasks', task_status: 'all', task_type_id: 'all' }.freeze

  def self.convert_params_to_attrs(params, attrs = {})
    attrs.reverse_merge!(DEFAULT_ATTRS)

    ATTRS_TO_PARAMS_MAP.each do |search_key, param_key|
      next if params[param_key].blank? || params[param_key] == 'all'

      attrs[search_key] = params[param_key]
    end
    return attrs if params[:type].blank?

    convert_type_param_to_attrs(attrs, params[:type])
  end

  def self.convert_attrs_to_filter_params(subscription)
    filters = convert_keys(subscription).reverse_merge!(order: 'updated,desc')
    return filters if subscription.include_issues && subscription.include_tasks

    if subscription.include_issues
      filters.reverse_merge!(DEFAULT_ISSUE_PARAMS)
    else
      filters.reverse_merge!(DEFAULT_TASK_PARAMS)
    end

    filters
  end

  private_class_method def self.convert_type_param_to_attrs(attrs, type_param)
    if type_param.in?(%w[issues all])
      attrs[:task_type_id] = attrs[:task_status] = nil
    end

    if type_param.in?(%w[tasks all])
      attrs[:issue_type_id] = attrs[:issue_status] = nil
    end

    attrs[:include_tasks] = false if type_param == 'issues'
    attrs[:include_issues] = false if type_param == 'tasks'

    attrs
  end

  private_class_method def self.convert_keys(subscription)
    attrs = {}

    ATTRS_TO_PARAMS_MAP.each do |search_key, filter_key|
      next if %i[category_id project_id user_id].include?(filter_key)

      val = subscription.send(search_key)
      next if val.blank?

      attrs[filter_key] = val
    end

    attrs
  end
end
