# frozen_string_literal: true

# TODO: add category nav

module CategoriesHelper
  def category_tags(category)
    content_tag :p, class: 'category-tags' do
      concat visible_tag(category)
      concat internal_tag(category)
    end
  end

  def category_header(category)
    content_tag :header, class: 'category-header' do
      concat breadcrumbs([['Categories', categories_path]])
      concat content_tag(:h1, link_to_unless_current(category.name, category))
      concat category_tags(category)
      concat category_nav(category)
      concat category_page_title(category)
    end
  end

  def category_page?(category)
    pages = [category_path(category), category_tasks_path(category),
             category_issues_path(category)]
    pages.any? { |path| current_page?(path) }
  end

  private

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

    def category_nav(category)
      content_tag :p, class: 'category-nav' do
        safe_join(category_nav_links(category), divider_with_spaces)
      end
    end

    def category_nav_links(category)
      links = [link_to_unless_current('Category', category),
               link_to_unless_current('Issues', category_issues_path(category)),
               link_to_unless_current('Tasks', category_tasks_path(category))]
      return links unless can?(:update, category)

      links.append(edit_category_link(category))
    end

    def edit_category_link(category)
      link_to_unless_current('Settings', edit_category_path(category),
                             class: 'destroy-link')
    end
end
