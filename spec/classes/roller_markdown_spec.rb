# frozen_string_literal: true

require "rails_helper"

RSpec.describe RollerMarkdown, type: :class do
  before { @roller_markdown = RollerMarkdown.new }

  subject { @roller_markdown }

  describe "#render" do
    context "when input is simple" do
      it "adds paragraph tags" do
        expect(subject.render("simple")).to eq("<p>simple</p>\n")
      end
    end

    context "when input contains _em_" do
      it "adds em tags" do
        expect(subject.render("_foo_")).to eq("<p><em>foo</em></p>\n")
      end
    end

    context "when input contains *em*" do
      it "adds em tags" do
        expect(subject.render("*foo*")).to eq("<p><em>foo</em></p>\n")
      end
    end

    context "when input contains __strong__" do
      it "adds strong tags" do
        expect(subject.render("__foo__")).to eq("<p><strong>foo</strong></p>\n")
      end
    end

    context "when input contains **strong**" do
      it "adds strong tags" do
        expect(subject.render("**foo**")).to eq("<p><strong>foo</strong></p>\n")
      end
    end

    context "when input contains ~~del~~" do
      it "adds del tags" do
        expect(subject.render("~~foo~~")).to eq("<p><del>foo</del></p>\n")
      end
    end

    context "when input contains `code`" do
      it "adds code tags" do
        expect(subject.render("`foo`"))
          .to eq("<p><code class=\"prettyprint\">foo</code></p>\n")
      end
    end

    context "when input contains ```codeblock```" do
      let(:html) do
        "<pre><code class=\"prettyprint lang-ruby\">foo = bar\n</code></pre>\n"
      end

      it "adds pre and code tags" do
        expect(subject.render("```ruby\nfoo = bar\n```")).to eq(html)
      end
    end

    context "when input contains html" do
      it "filters the tags" do
        expect(subject.render("<i>foo<i>")).to eq("<p>foo</p>\n")
      end
    end

    context "when input contains a script tag" do
      it "filters the tags" do
        expect(subject.render("<script>alert('foo');<script>"))
          .to eq("<p>alert(&#39;foo&#39;);</p>\n")
      end
    end

    context "when input contains '# heading'" do
      it "doesn't exchanges heading tags" do
        expect(subject.render("# Foo\n"))
          .to eq(%(<p class="markdown-heading markdown-h1">Foo</p>))
      end
    end
  end
end
