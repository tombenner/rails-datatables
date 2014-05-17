# rails-datatables

Datatables is a nifty jquery plugin that adds the ability to paginate, sort, and search your html tables. When dealing with large tables (more than a couple hundred rows) however, we run into performance issues. These can be fixed by using server-side pagination, but this breaks some datatables functionality.

`rails-datatables` is a wrapper around datatable's ajax methods that allow synchronization with server-side pagination in a rails app. It was inspired by this [railscast](http://railscasts.com/episodes/340-datatables). I needed to implement a similar solution in a couple projects I was working on so I extracted it out into a gem.

## Installation

Add these lines to your application's Gemfile:

    gem 'jquery-datatables-rails'
    gem 'rails-datatables'

And then execute:

    $ bundle

## Usage
*The following examples assume that we are setting up rails-datatables for an index of users from a `User` model*

### Generate
Run the following command:

    $ rails generate datatable User


This will generate a file named `user_datatable.rb` in `app/datatables`. Open the file and customize in the functions as directed by the comments

### Customize
```ruby
def sortable_columns
  # list columns inside the Array in string dot notation.
  # Example: 'users.email'
  @sortable_columns ||= []
end

def searchable_columns
  # list columns inside the Array in string dot notation.
  # Example: 'users.email'
  @searchable_columns ||= []
end
```

* For `sortable_columns`, assign an array of the database columns that correspond to the columns in our view table. For example `[users.f_name, users.l_name, users.bio]`. This array is used for sorting by various columns.

* For `searchable_columns`, assign an array of the database columns that you want searchable by datatables. For example `[users.f_name, users.l_name]`

This gives us:
```ruby
def sortable_columns
  @sortable_columns ||= ['users.f_name', 'users.l_name', 'users.bio']
end

def searchable_columns
  @searchable_columns ||= ['users.f_name', 'users.l_name']
end

```

### Map data
```ruby
def data
  records.map do |record|
    [
        # comma separated list of the values for each cell of a table row
        # example: record.attribute,
      ]
  end
end
```

This method builds a 2d array that is used by datatables to construct the html table. Insert the values you want on each column.

```ruby
def data
  records.map do |record|
    [
      record.f_name,
      record.l_name,
      record.bio
    ]
  end
end
```

#### Get Raw Records
```ruby
def get_raw_records
  # insert query here
end
```

This is where your query goes.

```ruby
def get_raw_records
  User.all
end
```

### Controller
Set up the controller to respond to JSON

```ruby
def index
  respond_to do |format|
    format.html
    format.json { render json: UserDatatable.new(view_context) }
  end
end
```

### View
* Set up an html `<table>` with a `<thead>` and `<tbody>`
* Add in your table headers if desired
* Don't add any rows to the body of the table, datatables does this automatically
* Add a data attribute to the `<table>` tag with the url of the JSON feed

The resulting view may look like this:

```erb
<table id="user-table", data-source="<%= users_path(format: :json) %>">
  <thead>
    <tr>
      <th>First Name</th>
      <th>Last Name</th>
      <th>Brief Bio</th>
    </tr>
  </thead>
  <tbody>
  </tbody>
</table>
```

### Javascript
Finally, the javascript to tie this all together. In the appropriate `js.coffee` file:

```coffeescript
$ ->
  $('#users-table').dataTable
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#users-table').data('source')
```

### Additional Notes

A `RailsDatatables::Base` inherited class can accept an options hash at initialization. This provides room for flexibility when required. Example:

```ruby
class UnrespondedMessagesDatatable < RailsDatatables::Base
  # customized methods here
end

datatable = UnrespondedMessagesDatatable.new(
  view_context, { :foo => { :bar => Baz.new }, :from => 1.month.ago }
)

datatable.options
#=> { :foo => { :bar => #<Baz:0x007fe9cb4e0220> }, :from => 2014-04-16 19:55:28 -0700 }
```

Also, a class that inherits from `RailsDatatables::Base` is not tied to an existing model, module, constant or any type of class in your Rails app. You can pass a name to your datatable class like this:


```
$ rails generate datatable users
# returns a users_datatable.rb file with a UsersDatatable class

$ rails generate datatable contact_messages
# returns a contact_messages_datatable.rb file with a ContactMessagesDatatable class

$ rails generate datatable UnrespondedMessages
# returns an unresponded_messages_datatable.rb file with an UnrespondedMessagesDatatable class
```


In the end, it's up to the developer which model(s), scope(s), relationship(s) (or else) to employ inside the datatable class to retrieve records from the database.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
