class SearchFiltersConverter
  def self.convert_params_to_attrs(params, attrs = {})
    attrs.reverse_merge!(SearchSubscription::DEFAULT_ATTRS)

    SearchSubscription::ATTRS_TO_PARAMS_MAP.each do |search_key, param_key|
      next if params[param_key].blank? || params[param_key] == 'all'

      attrs[search_key] = params[param_key]
    end
    return attrs if params[:type].blank?

    convert_type_param_to_attrs(attrs, params[:type])
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
end
