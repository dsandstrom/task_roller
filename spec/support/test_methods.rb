module TestMethods
  def map_class_id(search_results)
    search_results.map do |s|
      [s.class_name, s.id]
    end
  end
end
