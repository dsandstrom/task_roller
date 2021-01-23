# frozen_string_literal: true

# TODO: save html_url from payload as github_url

module Api
  module V1
    class WebhooksController < ActionController::API
      before_action :verify_github_signature

      # POST /api/v1/github
      def github
        head :ok
      end

      private

        def app_secret
          @app_secret ||= ENV['GITHUB_SECRET']
        end

        def request_signature
          @request_signature ||= request.env['HTTP_X_HUB_SIGNATURE_256']
        end

        def verify_github_signature
          unless app_secret.present? && request_signature.present?
            head :forbidden
            return
          end

          payload_body = request.body.read
          code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'),
                                         app_secret, payload_body)
          signature = "sha256=#{code}"
          return if Rack::Utils.secure_compare(signature, request_signature)

          head :unauthorized
        end
    end
  end
end
