# frozen_string_literal: true

# TODO: allow customizing which project & issue_type is picked
# TODO: import comments?
# TODO: use only master/main branch
# payload has "ref" => "refs/heads/master"
# "repository" "default_branch" => "master"

# https://docs.github.com/en/developers/webhooks-and-events/webhooks/webhook-events-and-payloads#push
# https://docs.github.com/en/rest/reference/repos#commits

module Api
  module V1
    class WebhooksController < ActionController::API
      before_action :verify_github_signature

      # POST /api/v1/github
      def github
        return true unless issue_payload? || commit_payload?

        if github_issue || github_commits
          head :ok
          return
        end

        dump_github_issue
        head :unprocessable_entity
      end

      private

        def issue_payload?
          issue_payload.present? && repo_payload.present?
        end

        def commit_payload?
          commits_payload&.any?
        end

        def app_secret
          @app_secret ||= ENV['GITHUB_WEBHOOK_SECRET']
        end

        def request_signature
          @request_signature ||= request.env['HTTP_X_HUB_SIGNATURE_256']
        end

        def issue_payload
          @issue_payload ||= params[:issue]
        end

        def commits_payload
          @commits_payload ||= params[:commits]
        end

        def user_payload
          @user_payload ||= issue_payload[:user]
        end

        def repo_payload
          @repo_payload ||= params[:repository]
        end

        def issue_type
          @issue_type ||= IssueType.first
        end

        def category
          @category ||= Category.find_or_create_by(name: 'Rails Application')
        end

        def project
          @project ||=
            category&.projects&.find_or_create_by(name: 'Uncategorized')
        end

        def user_params
          @user_params ||=
            { github_id: user_payload[:id],
              github_username: user_payload[:login],
              name: user_payload[:login] }
        end

        def issue_params
          @issue_params ||=
            { github_id: issue_payload[:id],
              github_url: issue_payload[:html_url],
              github_repo_id: repo_payload[:id],
              issue_type: issue_type,
              user: github_user,
              summary: issue_payload[:title],
              description: (issue_payload[:body].presence || 'Imported') }
        end

        def github_user_valid?
          %i[github_id github_username name].all? do |k|
            user_params[k].present?
          end
        end

        def github_user
          return unless user_payload

          @github_user ||= User.find_by(github_id: user_payload[:id])
          return @github_user if @github_user
          return unless github_user_valid?

          @github_user = User.new(user_params)
          @github_user.save(validate: false)
          @github_user
        end

        def github_issue
          return unless issue_payload?

          @github_issue ||= Issue.find_by(github_id: issue_payload[:id])
          return @github_issue if @github_issue
          return unless github_user

          @github_issue = project.issues.create!(issue_params)
          @github_issue.notify_github(issue_url(@github_issue))
        rescue ActiveRecord::RecordInvalid
          false
        end

        def github_commits
          return unless commits_payload&.any?

          commits_payload.each do |payload|
            process_commit(payload)
          end

          true
        end

        def commit_params(payload)
          { commit_sha: payload[:id], commit_html_url: payload[:url],
            commit_message: payload[:message] }
        end

        def process_commit(payload)
          return unless payload && payload[:committer] && payload[:message]

          user = process_user(payload[:committer])
          return unless user

          attrs = commit_params(payload)
          attrs[:commit_message].scan(RepoCallout::MESSAGE_REGEX) do |m, _a, _t|
            repo_callout =
              user.repo_callouts.build(attrs.merge(commit_message_part: m))
            perform_repo_callout_action(repo_callout)
          end
        end

        def perform_repo_callout_action(repo_callout)
          repo_callout.process_commit_message
          return unless repo_callout.save!

          repo_callout.perform_action
        rescue ActiveRecord::RecordInvalid
          logger.info "GitHub commit can't be process. RepoCallout is invalid:"
          logger.info repo_callout&.errors&.messages&.inspect
        end

        def process_user(payload)
          return unless payload[:username]

          user = User.find_by(github_username: payload[:username])
          return user if user

          # FIXME: commit doesn't send id, so not valid
          u = { github_id: payload[:id], github_username: payload[:username],
                name: payload[:name] }
          return if u.any? { |_, value| value.blank? }

          user = User.new(u)
          user.save(validate: false)
          user
        end

        def verify_github_signature
          unless app_secret.present? && request_signature.present?
            head :forbidden
            return
          end

          code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'),
                                         app_secret, request.body.read)
          signature = "sha256=#{code}"
          return if Rack::Utils.secure_compare(signature, request_signature)

          head :unauthorized
        end

        def dump_github_user
          logger.info "GitHub issue can't be created. User is invalid:"
          logger.info user_payload.inspect
        end

        def dump_github_issue
          return unless issue_payload && @github_issue

          logger.info "GitHub issue can't be created. Issue is invalid:"
          logger.info issue_payload.inspect
          logger.info @github_issue.errors&.messages&.inspect
        end
    end
  end
end
