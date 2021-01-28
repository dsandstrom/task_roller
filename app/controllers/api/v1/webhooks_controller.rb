# frozen_string_literal: true

# TODO: allow customizing which project, issue_type
# TODO: import comments?
# TODO: watch for commits to start/finish tasks

module Api
  module V1
    class WebhooksController < ActionController::API
      before_action :verify_github_signature

      # POST /api/v1/github
      def github
        if github_issue
          head :ok
          return
        end

        dump_github_issue
        head :unprocessable_entity
      end

      private

        def app_secret
          @app_secret ||= ENV['GITHUB_WEBHOOK_SECRET']
        end

        def request_signature
          @request_signature ||= request.env['HTTP_X_HUB_SIGNATURE_256']
        end

        def payload
          @payload ||= params[:issue]
        end

        def user_payload
          @user_payload ||= payload[:user]
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
            { github_id: user_payload[:id], github_url: user_payload[:html_url],
              name: user_payload[:login] }
        end

        def issue_params
          @issue_params ||=
            { github_id: payload[:id], github_url: payload[:html_url],
              issue_type: issue_type, user: github_user,
              summary: payload[:title], description: payload[:body] }
        end

        def github_user_valid?
          %i[github_id github_url name].all? { |k| user_params[k].present? }
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
          return true unless payload

          @github_issue ||= Issue.find_by(github_id: payload[:id])
          return @github_issue if @github_issue
          return unless github_user

          @github_issue = project.issues.create!(issue_params)
        rescue ActiveRecord::RecordInvalid
          nil
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
          logger.info "GitHub issue can't be created. Issue is invalid:"
          logger.info payload.inspect
          logger.info github_issue&.errors&.messages&.inspect
        end
    end
  end
end
