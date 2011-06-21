module MessagesHelper
  
  def sortable_column(col_name, sort_order)
    sort_order ||= 'asc'
    query_list = [].push('order=' + col_name + '_' + sort_order)
    if request.get?
      params.each {
        |k, v|
        if ( k != "controller" && k != "action" && k != "order" )
          query_list.push("#{k}=#{v}")
        end
      }
    end
    "<a href='/messages?" + query_list.join('&') +"'>" + col_name.capitalize! + "</a>"
  end
  
end
