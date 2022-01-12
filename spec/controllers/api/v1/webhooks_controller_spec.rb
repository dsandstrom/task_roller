# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::WebhooksController, type: :controller do
  let(:task) { Fabricate(:task) }
  let(:commit_user) do
    Fabricate(:user_worker, github_id: 4321, github_username: "login")
  end

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
          }
        },
        "repository" => {
          "id" => 543
        },
        "sender" => {
          "login" => "user", "id" => 876
        }
      }
    end

    let(:commit_push_params) do
      {
        "commits" => [
          {
            "url" => "#{api_url}/repos/test",
            "id" => "ssshhhaaa",
            "author" => {
              "name" => commit_user.name,
              "email" => commit_user.email,
              "username" => commit_user.github_username
            },
            "committer" => {
              "name" => commit_user.name,
              "email" => commit_user.email,
              "username" => commit_user.github_username
            },
            "message" => "Fix all the bugs"
          }
        ],
        "repository" => {
          "id" => 543
        },
        "pusher" => {
          "name" => "Codertocat",
          "email" => "pusher@example.com"
        },
        "sender" => {
          "login" => "Codertocat",
          "id" => "1234",
          "node_id" => "ttt",
          "avatar_url" => "https://avatars1.githubusercontent.com/u/1234?v=4",
          "gravatar_id" => "",
          "url" => "https://api.github.com/users/Codertocat",
          "html_url" => "https://github.com/Codertocat"
        }
      }
    end

    let(:api_url) do
      "https://api.github.com/repositories/543/issues/2/comments"
    end

    before do
      Fabricate(:issue_type)
      Fabricate(:user_reporter)
    end

    context "when secret is not set in the app" do
      before { ENV["GITHUB_WEBHOOK_SECRET"] = nil }

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
      before { ENV["GITHUB_WEBHOOK_SECRET"] = github_secret }

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
      before { ENV["GITHUB_WEBHOOK_SECRET"] = github_secret }

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
      before { ENV["GITHUB_WEBHOOK_SECRET"] = github_secret }

      context "test request" do
        let(:params) do
          { "name" => "Test", "repository" => { "name" => "Test" } }
        end

        before do
          code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"),
                                         github_secret,
                                         params.to_query)
          request.env["HTTP_X_HUB_SIGNATURE_256"] = "sha256=#{code}"
        end

        it "doesn't create a new app issue" do
          expect do
            post :github, params: params
          end.not_to change(Issue, :count)
        end

        it "returns a success response" do
          post :github, params: params
          expect(response).to be_successful
        end
      end

      context "for an issue" do
        context "action is 'opened'" do
          before do
            ENV["GITHUB_USER_TOKEN"] = "token"
            stub_request(:post, api_url)
            code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"),
                                           github_secret,
                                           issue_open_params.to_query)
            request.env["HTTP_X_HUB_SIGNATURE_256"] = "sha256=#{code}"
          end

          after { ENV["GITHUB_USER_TOKEN"] = nil }

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

            it "sets issue attributes" do
              post :github, params: issue_open_params

              issue = Issue.last
              expect(issue).not_to be_nil
              expect(issue.summary).to eq("New Issue API Test")
              expect(issue.description).to eq("Testing api")
              expect(issue.github_id).to eq(1234)
              expect(issue.github_repo_id).to eq(543)
              expect(issue.github_number).to eq(2)
            end

            it "sends new comment request" do
              post :github, params: issue_open_params

              expect(a_request(:post, api_url)).to have_been_made.once
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
              end.to change(User, :count).by(1)
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

          context "and body is nil" do
            let(:params) { issue_open_params }

            before do
              params["issue"]["body"] = nil
              code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"),
                                             github_secret,
                                             params.to_query)
              request.env["HTTP_X_HUB_SIGNATURE_256"] = "sha256=#{code}"
            end

            it "still creates a new issue" do
              expect do
                post :github, params: params
              end.to change(Issue, :count).by(1)
            end

            it "returns an success response" do
              post :github, params: params
              expect(response).to be_successful
            end
          end
        end
      end

      context "for a commit" do
        before do
          code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"),
                                         github_secret,
                                         commit_push_params.to_query)
          request.env["HTTP_X_HUB_SIGNATURE_256"] = "sha256=#{code}"
        end

        context "and user exists" do
          it "doesn't create a new user" do
            expect do
              post :github, params: commit_push_params
            end.not_to change(User, :count)
          end

          it "returns a success response" do
            post :github, params: commit_push_params
            expect(response).to be_successful
          end
        end

        context "and user doesn't exist" do
          before { commit_user.destroy }

          # it "creates a new user" do
          #   expect do
          #     post :github, params: commit_push_params
          #   end.to change(User, :count).by(1)
          # end

          it "returns a success response" do
            post :github, params: commit_push_params
            expect(response).to be_successful
          end
        end

        context "and commit message contains start and task #" do
          before do
            Fabricate(:task_assignee, task: task, assignee: commit_user)
            commit_push_params["commits"][0]["message"] =
              "Starts Task##{task.id}"
          end

          before do
            code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"),
                                           github_secret,
                                           commit_push_params.to_query)
            request.env["HTTP_X_HUB_SIGNATURE_256"] = "sha256=#{code}"
          end

          context "when task open and assigned to user" do
            it "creates a new progression" do
              expect do
                post :github, params: commit_push_params
              end.to change(task.progressions, :count).by(1)
            end

            it "doesn't create a review" do
              expect do
                post :github, params: commit_push_params
              end.not_to change(Review, :count)
            end

            it "updates the task's status" do
              expect do
                post :github, params: commit_push_params
                task.reload
              end.to change(task, :status)
            end

            it "returns a success response" do
              post :github, params: commit_push_params
              expect(response).to be_successful
            end
          end
        end

        context "and commit message contains fixes and task #" do
          before do
            Fabricate(:task_assignee, task: task, assignee: commit_user)
            commit_push_params["commits"][0]["message"] =
              "Fixes #{task.id}"
          end

          before do
            code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"),
                                           github_secret,
                                           commit_push_params.to_query)
            request.env["HTTP_X_HUB_SIGNATURE_256"] = "sha256=#{code}"
          end

          context "when task open and assigned to user" do
            it "creates a new review" do
              expect do
                post :github, params: commit_push_params
              end.to change(task.reviews, :count).by(1)
            end

            it "doesn't create a progression" do
              expect do
                post :github, params: commit_push_params
              end.not_to change(Progression, :count)
            end

            it "updates the task's status" do
              expect do
                post :github, params: commit_push_params
                task.reload
              end.to change(task, :status)
            end

            it "returns a success response" do
              post :github, params: commit_push_params
              expect(response).to be_successful
            end
          end
        end

        context "and commit message contains multiple task callouts" do
          let(:second_task) { Fabricate(:open_task) }

          before do
            Fabricate(:task_assignee, task: task, assignee: commit_user)
            commit_push_params["commits"][0]["message"] =
              "Some changes\n\nFixes #{task.id}\nFixes #{second_task.id}"
          end

          before do
            code = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"),
                                           github_secret,
                                           commit_push_params.to_query)
            request.env["HTTP_X_HUB_SIGNATURE_256"] = "sha256=#{code}"
          end

          context "when task open and assigned to user" do
            it "creates a new review" do
              expect do
                post :github, params: commit_push_params
              end.to change(task.reviews, :count).by(1)
            end

            it "creates a second review" do
              expect do
                post :github, params: commit_push_params
              end.to change(second_task.reviews, :count).by(1)
            end

            it "updates the task's status" do
              expect do
                post :github, params: commit_push_params
                task.reload
              end.to change(task, :status)
            end

            it "updates the second task's status" do
              expect do
                post :github, params: commit_push_params
                second_task.reload
              end.to change(second_task, :status)
            end

            it "returns a success response" do
              post :github, params: commit_push_params
              expect(response).to be_successful
            end
          end
        end
      end
    end
  end
end
