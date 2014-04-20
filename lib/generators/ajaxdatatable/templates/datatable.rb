class <%= model.classify.pluralize %>Datatable < RailsDatatables
  
  def initialize(view)
    @model_name = <%= model.classify %>
    @columns = # insert array of column names here
    @searchable_columns = #insert array of columns that will be searched
    super(view)
  end
  
private

    def data
      <%= model.tableize %>.map do |<%= model.tableize.singularize %>|
        [
          # comma separated list of the values for each cell of a table row
        ]
      end
    end

    def <%= model.tableize %>
      @<%= model.tableize %> ||= fetch_records
    end

    def get_raw_records
      # insert query here
    end
    
    def get_raw_record_count
      search_records(get_raw_records).count
    end
    
    # ==== Insert 'presenter'-like methods below if necessary
end
