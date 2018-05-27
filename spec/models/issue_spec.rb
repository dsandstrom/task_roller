# frozen_string_literal: true

require "rails_helper"

RSpec.describe Issue, type: :model do
  let(:reporter) { Fabricate(:user_reporter) }
  let(:project) { Fabricate(:project) }
  let(:issue_type) { Fabricate(:issue_type) }

  before do
    @issue = Issue.new(summary: "Summary", description: "Description",
                       user_id: reporter.id, project_id: project.id,
                       issue_type_id: issue_type.id)
  end

  subject { @issue }

  it { is_expected.to be_valid }

  it { is_expected.to respond_to(:summary) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:issue_type_id) }
  it { is_expected.to respond_to(:project_id) }
  it { is_expected.to respond_to(:category) }

  it { is_expected.to validate_presence_of(:summary) }
  it { is_expected.to validate_length_of(:summary).is_at_most(200) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_length_of(:description).is_at_most(2000) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:issue_type_id) }
  it { is_expected.to validate_presence_of(:project_id) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:issue_type) }
  it { is_expected.to belong_to(:project) }
  it { is_expected.to have_many(:tasks) }
  it { is_expected.to have_many(:comments).dependent(:destroy) }

  # CLASS

  # INSTANCE

  describe "#tasks" do
    let(:issue) { Fabricate(:issue) }

    context "when destroying task" do
      it "nullifies tasks" do
        task = Fabricate(:task, issue: issue)

        expect do
          issue.destroy
          task.reload
        end.to change(task, :issue_id).to(nil)
      end
    end
  end

  describe "#description_html" do
    context "when description is simple" do
      before { subject.description = "simple" }

      it "adds paragraph tags" do
        expect(subject.description_html).to eq("<p>simple</p>\n")
      end
    end

    context "when description contains _em_" do
      before { subject.description = "_foo_" }

      it "adds em tags" do
        expect(subject.description_html).to eq("<p><em>foo</em></p>\n")
      end
    end

    context "when description contains *em*" do
      before { subject.description = "*foo*" }

      it "adds em tags" do
        expect(subject.description_html).to eq("<p><em>foo</em></p>\n")
      end
    end

    context "when description contains __strong__" do
      before { subject.description = "__foo__" }

      it "adds strong tags" do
        expect(subject.description_html)
          .to eq("<p><strong>foo</strong></p>\n")
      end
    end

    context "when description contains **strong**" do
      before { subject.description = "**foo**" }

      it "adds strong tags" do
        expect(subject.description_html)
          .to eq("<p><strong>foo</strong></p>\n")
      end
    end

    context "when description contains ~~del~~" do
      before { subject.description = "~~foo~~" }

      it "adds del tags" do
        expect(subject.description_html)
          .to eq("<p><del>foo</del></p>\n")
      end
    end

    context "when description contains `code`" do
      before { subject.description = "`foo`" }

      it "adds code tags" do
        expect(subject.description_html)
          .to eq("<p><code class=\"prettyprint\">foo</code></p>\n")
      end
    end

    context "when description contains ```codeblock```" do
      before { subject.description = "```ruby\nfoo = bar\n```" }

      let(:html) do
        "<pre><code class=\"prettyprint lang-ruby\">foo = bar\n</code></pre>\n"
      end

      it "adds pre and code tags" do
        expect(subject.description_html).to eq(html)
      end
    end

    context "when description contains html" do
      before { subject.description = "<i>foo<i>" }

      it "filters the tags" do
        expect(subject.description_html)
          .to eq("<p>foo</p>\n")
      end
    end

    context "when description contains a script tag" do
      before { subject.description = "<script>alert('foo');<script>" }

      it "filters the tags" do
        expect(subject.description_html)
          .to eq("<p>alert(&#39;foo&#39;);</p>\n")
      end
    end
  end
end
