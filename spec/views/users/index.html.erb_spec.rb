# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/index", type: :view do
  let(:first_user_reporter) { Fabricate(:user_reporter) }
  let(:second_user_reporter) { Fabricate(:user_reporter) }
  let(:first_user_reviewer) { Fabricate(:user_reviewer) }
  let(:second_user_reviewer) { Fabricate(:user_reviewer) }
  let(:first_user_worker) { Fabricate(:user_worker) }
  let(:second_user_worker) { Fabricate(:user_worker) }

  before(:each) do
    assign(:reviewers, [first_user_reviewer, second_user_reviewer])
    assign(:reporters, [first_user_reporter, second_user_reporter])
    assign(:workers, [first_user_worker, second_user_worker])
  end

  it "renders a list of user/reporters" do
    render
    assert_select "#user-#{first_user_reporter.id}"
    assert_select "#user-#{second_user_reporter.id}"
  end

  it "renders a list of user/reviewers" do
    render
    assert_select "#user-#{first_user_reviewer.id}"
    assert_select "#user-#{second_user_reviewer.id}"
  end

  it "renders a list of user/workers" do
    render
    assert_select "#user-#{first_user_worker.id}"
    assert_select "#user-#{second_user_worker.id}"
  end
end
