# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project, type: :model do
  let(:category) { Fabricate(:category) }

  before do
    @project = Project.new(name: "Project Name", category_id: category.id)
  end

  subject { @project }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:visible) }
  it { is_expected.to respond_to(:internal) }
  it { is_expected.to respond_to(:category_id) }

  it { is_expected.to belong_to(:category) }

  it { is_expected.to have_many(:issues) }
  it { is_expected.to have_many(:tasks) }
  it { is_expected.to have_many(:project_issue_subscriptions) }
  it { is_expected.to have_many(:project_task_subscriptions) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:name) }
  it do
    is_expected.to validate_uniqueness_of(:name)
      .case_insensitive.scoped_to(:category_id)
  end
  it { is_expected.to validate_length_of(:name).is_at_most(250) }
  it { is_expected.to validate_presence_of(:category_id) }

  describe "#issues" do
    let(:project) { Fabricate(:project) }

    context "when destroying Project" do
      it "destroys its issues" do
        Fabricate(:issue, project: project)
        Fabricate(:issue)

        expect do
          project.destroy
        end.to change(Issue, :count).by(-1)
      end
    end
  end

  describe "#tasks" do
    let(:project) { Fabricate(:project) }

    context "when destroying Project" do
      it "destroys its tasks" do
        Fabricate(:task, project: project)
        Fabricate(:task)

        expect do
          project.destroy
        end.to change(Task, :count).by(-1)
      end
    end
  end
end
