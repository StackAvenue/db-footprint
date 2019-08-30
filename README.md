# db-footprint
Track changes to your Phoenix models


Track changes to your models, for auditing or versioning. See how a model looked
at any stage in its lifecycle, revert it to any version, or restore it after it
has been destroyed.


### 1.b. Installation


1. Add a `versions` table to your database:
	```
    mix compile
    ```

    ```
    mix db_footprint.install
    ```

    ```
    mix ecto.migrate
    ```

### TODOS:

-> Fix, rerunning mix db_footprint handling
-> puts it in depts
