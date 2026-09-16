module SetupVerification
  extend ActiveSupport::Concern

  class_methods do
    # copied from CanCanCommunity - lib/cancan/controller_additions.rb
    def check_for_types(options = {})
      block = proc do |controller|
        next if IssueType.any? && TaskType.any?
        next if options[:unless] && controller.send(options[:unless])

        if IssueType.none?
          raise ApplicationError::MissingIssueTypes, 'Issue Types are required'
        end

        raise ApplicationError::MissingTaskTypes, 'Task Types are required'
      end

      send(:before_action, options.slice(:only, :except), &block)
    end

    def check_for_projects(options = {})
      block = proc do |controller|
        next if Project.all_totally_visible.accessible_by(current_ability).any?
        next if options[:unless] && controller.send(options[:unless])

        raise ApplicationError::MissingProjects, 'Projects are required'
      end

      send(:before_action, options.slice(:only, :except), &block)
    end
  end
end
