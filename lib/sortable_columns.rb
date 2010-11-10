module SortableColumns
  
  class ParameterError < StandardError; end
  
  def sortable_order(sortable, options = {}, function = '')
    if params[:sort_by] && params[:order]
      validate_params(sortable)
      store_sort(sortable)
      if sortable.columns_hash[params[:sort_by]].type == :string
        return "#{function}(#{params.delete(:sort_by)}) #{params.delete(:order)}"
      else
        return "#{params.delete(:sort_by)} #{params.delete(:order)}"
      end
    else
      if session[:sortable_columns] && session[:sortable_columns][sortable.to_s.downcase.to_sym]
        column = session[:sortable_columns][sortable.to_s.downcase.to_sym].keys.first
        if sortable.columns_hash[column.to_s].type == :string
          return "#{function}(#{column.to_s}) #{session[:sortable_columns][sortable.to_s.downcase.to_sym][column.to_sym]}"
        else
          return "#{column.to_s} #{session[:sortable_columns][sortable.to_s.downcase.to_sym][column.to_sym]}"
        end
      else
        return options[:default]
      end
    end
  end
  
private

  def validate_params(sortable)
    raise ParameterError.new("#{sortable} has no column \"#{params[:sort_by]}\".") unless sortable.column_names.include?(params[:sort_by])
    raise ParameterError.new("Order must be \"asc\" or \"desc\"") unless params[:order] == "asc" || params[:order] == "desc"
  end

  def store_sort(sortable)
    session[:sortable_columns] ||= Hash.new
    session[:sortable_columns][sortable.to_s.downcase.to_sym] = {params[:sort_by].to_sym => params[:order]}
  end
  
end
