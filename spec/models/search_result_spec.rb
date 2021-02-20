# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchResult, type: :model do
  before { @search_result = SearchResult.new }

  subject { @search_result }

  it { is_expected.to respond_to(:summary) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:closed) }
  it { is_expected.to respond_to(:opened_at) }
  it { is_expected.to respond_to(:issue_type_id) }
  # TODO: use task_id for both?
  # will make belong_tos more complicated
  # it { is_expected.to respond_to(:task_type_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:project_id) }
  it { is_expected.to respond_to(:issue_id) }
  it { is_expected.to respond_to(:class_name) }
  it { is_expected.to respond_to(:created_at) }
  it { is_expected.to respond_to(:updated_at) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:project) }
  it { is_expected.to respond_to(:category) }

  it { is_expected.to belong_to(:issue_type) }
  # it { is_expected.to belong_to(:task_type) }

  it { is_expected.to belong_to(:issue) }

  it { is_expected.to have_many(:task_assignees) }
  it { is_expected.to have_many(:assignees) }
end
