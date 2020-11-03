# frozen_string_literal: true

module CategoriesHelper
  # TODO: combine with project_tags
  def category_tags(category)
    content_tag :p, class: 'category-tags' do
      concat category_visible_tag(category)
      concat category_internal_tag(category)
    end
  end

  def category_header(category)
    content_tag :header, class: 'category-header' do
      concat breadcrumbs([['Categories', categories_path]])
      concat content_tag(:h1, link_to_unless_current(category.name, category))
      concat category_tags(category)
      concat category_page_title(category)
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

    def category_page_title(category)
      title =
        case params[:controller]
        when 'issues'
          issues_page_title(category.name)
        when 'tasks'
          tasks_page_title(category.name)
        else
          categories_page_title(category)
        end
      enable_page_title title
    end

    def categories_page_title(category)
      if params[:action] == 'edit'
        "Edit Category: #{category.name}"
      else
        "Category: #{category.name}"
      end
    end
end
