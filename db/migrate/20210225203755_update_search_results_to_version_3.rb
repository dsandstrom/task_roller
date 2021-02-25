class UpdateSearchResultsToVersion3 < ActiveRecord::Migration[6.1]
  def change
    update_view :search_results, version: 3, revert_to_version: 2
  end
end
