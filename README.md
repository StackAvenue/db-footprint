# db-footprint
Track changes to your Phoenix models


Track changes to your models, for auditing or versioning. See how a model looked
at any stage in its lifecycle, revert it to any version, or restore it after it
has been destroyed.


### 1. Installation


1. Add a `versions` table to your database:
	```
	Put following inside the deps function of mix.exs
	{:db_footprint, git: "git@github.com:StackAvenue/db-footprint.git"}
	```

	```
	mix deps.get
	```

	```
	mix deps.compile
	```
	
	```
    mix compile
    ```

    ```
    mix db_footprint.install
    ```

    ```
    mix db_footprint.add_trigger table_name_1 table_name_2
    ```

    ```
    mix ecto.migrate
    ```

