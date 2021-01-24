# frozen_string_literal: true

# TODO: allow customizing which project, issue_type
# TODO: save github user without email

module Api
  module V1
    class WebhooksController < ActionController::API
      before_action :verify_github_signature

      # POST /api/v1/github
      def github
        find_or_create_issue!
        head :ok
      rescue ActiveRecord::RecordInvalid
        logger.info "GitHub issue can't be created. Issue is invalid:"
        logger.info payload.inspect
        head :unprocessable_entity
      end

      private

        def app_secret
          @app_secret ||= ENV['GITHUB_SECRET']
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

        def github_user
          User.find_by(github_id: user_payload[:id]) ||
            User.create!(github_id: user_payload[:id],
                         github_url: user_payload[:html_url],
                         name: user_payload[:login],
                         employee_type: 'Reporter',
                         email: 'test@email.com')
        rescue ActiveRecord::RecordInvalid
          logger.info "GitHub issue can't be created. User is invalid:"
          logger.info user_payload.inspect
          nil
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

        def find_or_create_issue!
          Issue.find_by(github_id: payload[:id]) ||
            project.issues.create!(github_id: payload[:id],
                                   github_url: payload[:html_url],
                                   issue_type: issue_type,
                                   user: github_user,
                                   summary: payload[:title],
                                   description: payload[:body])
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
    end
  end
end
