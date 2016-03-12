#ActiveRecord Lite

ActiveRecord Lite is an Object Relational Mapping (ORM) that translates rows of a SQL table into their corresponding Ruby class. It is inspired by the ActiveRecord library used in Rails.

##Documentation

ActiveRecord Lite provides the following functionality:

##SQLObject class

`::finalize`: creates setter and getter methods for all columns in the corresponding table using Rub's metaprogramming method `#define_method`.

`::columns`: returns an array of all the columns in the corresponding table as symbols.

`::all`: returns an array of all the rows in the corresponding table as instances.

`::find(id)`: returns a row in the corresponding table with the specified `id` as an instance.

`::where(params)`: takes a hash of `params` and returns an array of instances from the corresponding table that meet the specified parameters.

`::table_name`: returns the instance variable of the table name or lazy instantiates the table name as the snake_case pluralized form of the class name.

`::table_name=(table_name)`: takes an argument `table_name` and sets the instance variable of the table name to that value.

`#attributes`: returns the names of all the object's attributes.

`#attribute_values`: returns the values of all the object's attributes

`#insert`: inserts an object into its corresponding table as a new row.

`#update`: updates an object's entry in the database.

`#save`: updates or inserts object's entry depending if it already exists.

`#delete`: deletes an object's entry in the database.

`#belongs_to(name, options)`: takes a model name and an optional options hash to override defaults and creates a method called `#name`. The generated method returns instances of the model name whose id matches the foreign key held by the object calling the method.

`#has_many(name, options)`: like `#belongs_to` but returns instances of the model name whose foreign_key matches the id of the object calling the method.

`#has_one_through(name, through_name, source_name)`: takes three arguments: the `name` of the target model class, the `through_name` of the intermediary class, and the `source_name` of the class calling the method, and creates a method called `#name`. The generated method returns an instance of `name` whose id matches the foreign key of the `through_name` object whose id matches the foreign key of the `source_name` object that is calling the method.

`#has_many_through(name, through_name, source_name)`: takes three arguments: the `name` of the target model class, the `through_name` of the intermediary class, and the `source_name` of the class calling the method, and creates a method called `#name`. The generated method returns instances of `name` whose foreign key matches the id of the `through_name` object whose foreign key matches the id of the `source_name` object that is calling the method.
