# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::WebhooksController, type: :controller do
  describe "POST #github" do
    let(:github_secret) { "secret" }
    let(:api_url) { "https://api.github.com" }
    let(:category_name) { "Rails Application" }
    let(:project_name) { "Uncategorized" }
    let(:issue_open_params) do
      {
        "issue" => {
          "url" => "#{api_url}/repos/user/repo/issues/2",
          "repository_url" => "#{api_url}/repos/user/repo",
          "labels_url" => "#{api_url}/repos/user/repo/issues/2/labels{/name}",
          "comments_url" => "#{api_url}/repos/user/repo/issues/2/comments",
          "events_url" => "#{api_url}/repos/user/repo/issues/2/events",
          "html_url" => "https://github.com/user/repo/issues/2",
          "id" => 1234,
          "node_id" => "yyy=",
          "number" => 2,
          "title" => "New Issue API Test",
          "user" => {
            "login" => "user", "id" => 4321,
            "node_id" => "zzz=",
            "avatar_url" => "https://avatars.githubusercontent.com/u/4321",
            "gravatar_id" => "",
            "url" => "#{api_url}/users/user",
            "html_url" => "https://github.com/user",
            "followers_url" => "#{api_url}/users/user/followers",
            "following_url" => "#{api_url}/users/user/following{/other_user}",
            "gists_url" => "#{api_url}/users/user/gists{/gist_id}",
            "starred_url" => "#{api_url}/users/user/starred{/owner}{/repo}",
            "subscriptions_url" => "#{api_url}/users/user/subscriptions"
          },
          "labels" => [], "state" => "open", "locked" => false,
          "assignee" => nil, "assignees" => [], "milestone" => nil,
          "comments" => 0, "created_at" => "2021-01-23T20:52:46Z",
          "updated_at" => "2021-01-23T20:52:46Z", "closed_at" => nil,
          "author_association" => "OWNER", "active_lock_reason" => nil,
          "body" => "Testing api", "performed_via_github_app" => nil
        },
        "webhook" => {
          "action" => "github",
          "issue" => {
            "url" => "#{api_url}/repos/user/repo/issues/2",
            "repository_url" => "#{api_url}/repos/user/repo",
            "labels_url" => "#{api_url}/repos/user/repo/issues/2/labels{/name}",
            "comments_url" => "#{api_url}/repos/user/repo/issues/2/comments",
            "events_url" => "#{api_url}/repos/user/repo/issues/2/events",
            "html_url" => "https://github.com/user/repo/issues/2",
            "id" => 1234,
            "node_id" => "yyy=", "number" => 2,
            "title" => "New Issue API Test",
            "user" => {
              "login" => "user",
              "id" => 4321,
              "node_id" => "zzz=",
              "avatar_url" => "https://avatars.githubusercontent.com/u/4321",
              "gravatar_id" => "",
              "url" => "#{api_url}/users/user",
              "html_url" => "https://github.com/user",
              "followers_url" => "#{api_url}/users/user/followers",
              "following_url" => "#{api_url}/users/user/following{/other_user}",
              "gists_url" => "#{api_url}/users/user/gists{/gist_id}",
              "starred_url" => "#{api_url}/users/user/starred{/owner}{/repo}",
              "subscriptions_url" => "#{api_url}/users/user/subscriptions",
              "organizations_url" => "#{api_url}/users/user/orgs",
              "repos_url" => "#{api_url}/users/user/repos",
              "events_url" => "#{api_url}/users/user/events{/privacy}",
              "received_events_url" => "#{api_url}/users/user/received_events",
              "type" => "User",
              "site_admin" => false
            },
            "labels" => [], "state" => "open", "locked" => false,
            "assignee" => nil, "assignees" => [], "milestone" => nil,
            "comments" => 0, "created_at" => "2021-01-23T20:52:46Z",
            "updated_at" => "2021-01-23T20:52:46Z", "closed_at" => nil,
            "author_association" => "OWNER", "active_lock_reason" => nil,
            "body" => "Testing api", "performed_via_github_app" => nil
          },
          "repository" => {
            "id" => 543
          },
          "sender" => {
            "login" => "user", "id" => 876
          }
        }
      }
    end

    before do
      Fabricate(:issue_type)
      Fabricate(:user_reporter)
    end

    context "when secret is not set in the app" do
      before { ENV["GITHUB_SECRET"] = nil }

      context "action is 'opened'" do
        before do
          code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"),
                                         github_secret,
                                         issue_open_params.to_query)
          request.env["HTTP_X_HUB_SIGNATURE_256"] = "sha256=#{code}"
        end

        it "returns an forbidden response" do
          post :github, params: issue_open_params
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context "when secret not sent in payload" do
      before { ENV["GITHUB_SECRET"] = github_secret }

      context "action is 'opened'" do
        before do
          request.env["HTTP_X_HUB_SIGNATURE_256"] = nil
        end

        it "returns an forbidden response" do
          post :github, params: issue_open_params
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context "when secret sent is wrong" do
      before { ENV["GITHUB_SECRET"] = github_secret }

      context "action is 'opened'" do
        before do
          code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"),
                                         "wrong",
                                         issue_open_params.to_query)
          request.env["HTTP_X_HUB_SIGNATURE_256"] = "sha256=#{code}"
        end

        it "returns an unauthorized response" do
          post :github, params: issue_open_params
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context "when secret matches" do
      before { ENV["GITHUB_SECRET"] = github_secret }

      context "action is 'opened'" do
        before do
          code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"),
                                         github_secret,
                                         issue_open_params.to_query)
          request.env["HTTP_X_HUB_SIGNATURE_256"] = "sha256=#{code}"
        end

        context "when category and project don't exist" do
          it "returns a success response" do
            post :github, params: issue_open_params
            expect(response).to be_successful
          end

          it "creates a new category" do
            expect do
              post :github, params: issue_open_params
            end.to change(Category, :count).by(1)
          end

          it "creates a new project" do
            expect do
              post :github, params: issue_open_params
            end.to change(Project, :count).by(1)
          end

          it "creates a new app issue" do
            expect do
              post :github, params: issue_open_params
            end.to change(Issue, :count).by(1)
          end

          it "sets issue summary" do
            post :github, params: issue_open_params
            issue = Issue.last
            expect(issue).not_to be_nil
            expect(issue.summary).to eq("New Issue API Test")
          end

          it "sets issue description" do
            post :github, params: issue_open_params
            issue = Issue.last
            expect(issue).not_to be_nil
            expect(issue.description).to eq("Testing api")
          end

          it "sets issue github_id" do
            post :github, params: issue_open_params
            issue = Issue.last
            expect(issue).not_to be_nil
            expect(issue.github_id).to eq(1234)
          end
        end

        context "when project doesn't exist" do
          let!(:category) { Fabricate(:category, name: category_name) }

          it "returns a success response" do
            post :github, params: issue_open_params
            expect(response).to be_successful
          end

          it "doesn't create a new category" do
            expect do
              post :github, params: issue_open_params
            end.not_to change(Category, :count)
          end

          it "creates a new project" do
            expect do
              post :github, params: issue_open_params
            end.to change(category.projects, :count).by(1)
          end

          it "creates a new app issue" do
            expect do
              post :github, params: issue_open_params
            end.to change(Issue, :count).by(1)
          end
        end

        context "when project exists" do
          let!(:category) { Fabricate(:category, name: category_name) }
          let!(:project) do
            Fabricate(:project, category: category, name: project_name)
          end

          it "returns a success response" do
            post :github, params: issue_open_params
            expect(response).to be_successful
          end

          it "doesn't create a new category" do
            expect do
              post :github, params: issue_open_params
            end.not_to change(Category, :count)
          end

          it "doesn't create a new project" do
            expect do
              post :github, params: issue_open_params
            end.not_to change(Project, :count)
          end

          it "creates a new app issue" do
            expect do
              post :github, params: issue_open_params
            end.to change(Issue, :count).by(1)
          end
        end

        context "and user is new" do
          it "creates a new user" do
            expect do
              post :github, params: issue_open_params
            end.to change(User.reporters, :count).by(1)
          end

          it "sets issue user_id" do
            post :github, params: issue_open_params
            issue = Issue.last
            expect(issue).not_to be_nil
            expect(issue.user_id).not_to be_nil
          end

          it "returns a success response" do
            post :github, params: issue_open_params
            expect(response).to be_successful
          end
        end

        context "and user exists" do
          before do
            Fabricate(:user_reviewer,
                      github_id: issue_open_params["issue"]["user"]["id"])
          end
          it "doesn't create a new user" do
            expect do
              post :github, params: issue_open_params
            end.not_to change(User, :count)
          end

          it "sets issue user_id" do
            post :github, params: issue_open_params
            issue = Issue.last
            expect(issue).not_to be_nil
            expect(issue.user_id).not_to be_nil
          end

          it "returns a success response" do
            post :github, params: issue_open_params
            expect(response).to be_successful
          end
        end

        context "and new user is invalid" do
          before do
            issue_open_params["issue"]["user"]["login"] = nil
            code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"),
                                           github_secret,
                                           issue_open_params.to_query)
            request.env["HTTP_X_HUB_SIGNATURE_256"] = "sha256=#{code}"
          end

          it "doesn't create a new issue" do
            expect do
              post :github, params: issue_open_params
            end.not_to change(Issue, :count)
          end

          it "returns an error response" do
            post :github, params: issue_open_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context "and issue is invalid" do
          before do
            issue_open_params["issue"]["title"] = nil
            code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"),
                                           github_secret,
                                           issue_open_params.to_query)
            request.env["HTTP_X_HUB_SIGNATURE_256"] = "sha256=#{code}"
          end

          it "doesn't create a new issue" do
            expect do
              post :github, params: issue_open_params
            end.not_to change(Issue, :count)
          end

          it "returns an error response" do
            post :github, params: issue_open_params
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context "and issue already exists" do
          before do
            Fabricate(:issue, github_id: issue_open_params["issue"]["id"])
            Fabricate(:user_reporter,
                      github_id: issue_open_params["issue"]["user"]["id"])
          end

          it "doesn't create a new issue" do
            expect do
              post :github, params: issue_open_params
            end.not_to change(Issue, :count)
          end

          it "returns an success response" do
            post :github, params: issue_open_params
            expect(response).to be_successful
          end
        end
      end
    end
  end
end
