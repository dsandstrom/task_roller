# frozen_string_literal: true

module CategoriesHelper
  # TODO: combine with project_tags
  def category_tags(category)
    content_tag :p, class: 'category-tags' do
      concat category_visible_tag(category)
      concat category_internal_tag(category)
    end
  end

  private

    def category_tag(text, klass)
      content_tag :span, text, class: "tag tag-#{klass}"
    end

    def category_visible_tag(category)
      if category.visible?
        text = 'Visible'
        klass = 'visible'
      else
        text = 'Invisible'
        klass = 'invisible'
      end

      category_tag text, klass
    end

    def category_internal_tag(category)
      if category.internal?
        text = 'Internal'
        klass = 'internal'
      else
        text = 'External'
        klass = 'external'
      end

      category_tag text, klass
    end
end
