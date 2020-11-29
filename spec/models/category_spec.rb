# frozen_string_literal: true

require "rails_helper"

RSpec.describe Category, type: :model do
  before { @category = Category.new(name: "Category Name") }

  subject { @category }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:visible) }
  it { is_expected.to respond_to(:internal) }

  it { is_expected.to have_many(:projects).dependent(:destroy) }
  it { is_expected.to have_many(:issues).through(:projects) }
  it { is_expected.to have_many(:tasks).through(:projects) }
  it do
    is_expected.to have_many(:category_issues_subscriptions).dependent(:destroy)
  end
  it do
    is_expected.to have_many(:category_tasks_subscriptions).dependent(:destroy)
  end
  it { is_expected.to have_many(:issue_subscribers) }
  it { is_expected.to have_many(:task_subscribers) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(200) }

  # CLASS

  describe ".all_visible" do
    before { Fabricate(:invisible_category) }

    it "returns categories with true visible" do
      category = Fabricate(:category)
      expect(Category.all_visible).to eq([category])
    end
  end

  describe ".all_invisible" do
    before { Fabricate(:category) }

    it "returns categories with false visible" do
      category = Fabricate(:invisible_category)
      expect(Category.all_invisible).to eq([category])
    end
  end

  # INSTANCE

  describe "#issues_subscription" do
    let(:user) { Fabricate(:user_worker) }
    let(:category) { Fabricate(:category) }

    before do
      Fabricate(:category_issues_subscription, user: user)
      Fabricate(:category_issues_subscription, category: category)
    end

    context "when no options" do
      context "when no subscription for the category" do
        it "returns nil" do
          expect(category.issues_subscription(user)).to be_nil
        end
      end

      context "when subscription for the category" do
        let(:subscription) do
          Fabricate(:category_issues_subscription, user: user,
                                                   category: category)
        end

        before { subscription }

        it "returns it" do
          expect(category.issues_subscription(user)).to eq(subscription)
        end
      end
    end

    context "when init is true" do
      context "when no subscription for the category" do
        it "returns a new one" do
          expect(category.issues_subscription(user, init: true))
            .to be_a_new(CategoryIssuesSubscription)
        end
      end

      context "when subscription for the category" do
        let(:subscription) do
          Fabricate(:category_issues_subscription, user: user,
                                                   category: category)
        end

        before { subscription }

        it "returns it" do
          expect(category.issues_subscription(user, init: true))
            .to eq(subscription)
        end
      end
    end
  end

  describe "#subscribed_to_issues?" do
    let(:user) { Fabricate(:user_worker) }
    let(:category) { Fabricate(:category) }

    before do
      Fabricate(:category_issues_subscription, user: user)
      Fabricate(:category_issues_subscription, category: category)
    end

    context "when no subscription for the category" do
      it "returns false" do
        expect(category.subscribed_to_issues?(user)).to eq(false)
      end
    end

    context "when subscription for the category" do
      let(:subscription) do
        Fabricate(:category_issues_subscription, user: user, category: category)
      end

      before { subscription }

      it "returns true" do
        expect(category.subscribed_to_issues?(user)).to eq(true)
      end
    end
  end

  describe "#tasks_subscription" do
    let(:user) { Fabricate(:user_worker) }
    let(:category) { Fabricate(:category) }

    before do
      Fabricate(:category_tasks_subscription, user: user)
      Fabricate(:category_tasks_subscription, category: category)
    end

    context "when no options" do
      context "when no subscription for the category" do
        it "returns nil" do
          expect(category.tasks_subscription(user)).to be_nil
        end
      end

      context "when subscription for the category" do
        let(:subscription) do
          Fabricate(:category_tasks_subscription, user: user,
                                                  category: category)
        end

        before { subscription }

        it "returns it" do
          expect(category.tasks_subscription(user)).to eq(subscription)
        end
      end
    end

    context "when init is true" do
      context "when no subscription for the category" do
        it "returns a new one" do
          expect(category.tasks_subscription(user, init: true))
            .to be_a_new(CategoryTasksSubscription)
        end
      end

      context "when subscription for the category" do
        let(:subscription) do
          Fabricate(:category_tasks_subscription, user: user,
                                                  category: category)
        end

        before { subscription }

        it "returns it" do
          expect(category.tasks_subscription(user, init: true))
            .to eq(subscription)
        end
      end
    end
  end

  describe "#subscribed_to_tasks?" do
    let(:user) { Fabricate(:user_worker) }
    let(:category) { Fabricate(:category) }

    before do
      Fabricate(:category_tasks_subscription, user: user)
      Fabricate(:category_tasks_subscription, category: category)
    end

    context "when no subscription for the category" do
      it "returns false" do
        expect(category.subscribed_to_tasks?(user)).to eq(false)
      end
    end

    context "when subscription for the category" do
      let(:subscription) do
        Fabricate(:category_tasks_subscription, user: user, category: category)
      end

      before { subscription }

      it "returns true" do
        expect(category.subscribed_to_tasks?(user)).to eq(true)
      end
    end
  end

  describe "#name_and_tag" do
    context "when category is visible" do
      let(:category) { Fabricate(:category) }

      it "returns name only" do
        expect(category.name_and_tag).to eq(category.name)
      end
    end

    context "when category is internal" do
      let(:category) { Fabricate(:internal_category) }

      it "returns name only" do
        expect(category.name_and_tag).to eq(category.name)
      end
    end

    context "when category is invisible" do
      let(:category) { Fabricate(:invisible_category) }

      it "returns name and archived tag" do
        expect(category.name_and_tag).to eq("#{category.name} (archived)")
      end
    end

    context "when category is visible, but missing name" do
      let(:category) { Fabricate(:category) }

      before { category.name = nil }

      it "returns string" do
        expect(category.name_and_tag).to eq("")
      end
    end
  end
end
