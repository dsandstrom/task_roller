class CreateSearchResults < ActiveRecord::Migration[6.1]
  def change
    create_view :search_results
  end
end
