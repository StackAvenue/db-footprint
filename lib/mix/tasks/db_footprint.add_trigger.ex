defmodule Mix.Tasks.DbFootprint.AddTrigger do
	use Mix.Task
  alias Mix.DbFootprint

	@shortdoc "Add Triggers to the provided modules"

	def run(args) do
		DbFootprint.generator_paths()
      |> copy_new_files(args)
    DbFootprint.print_shell_instructions()
  end

  def copy_new_files(paths, args) do
    #arg_1 = "ctx_app: discuss" (directory or project where this needs to be set up i.e root element of the project)
    #arg_2 = "rel_path: priv/repo/migrations/1567101445_create_versions.exs"

    migration_path = DbFootprint.context_app_path(Mix.Project.config[:app], "priv/repo/migrations/#{DbFootprint.timestamp()}_add_triggers.exs")

    #migration_path = "priv/repo/migrations/1567101445_add_triggers.exs"
    #IO.inspect("----------")
    #IO.inspect migration_path
    #arg_1 = paths: [".", :db_footprint]
    #arg_2 = "source_dir: priv/templates/db_footprint.add_trigger"
    #arg_3 = "binding: "
    #arg_4 = "[{:eex, "add_triggers.ex", "priv/repo/migrations/1567101445_add_triggers.exs"}]"
    #args = ["table_name_1", "table_name_2"]

    DbFootprint.new_copy_from paths, "priv/templates/db_footprint.install", args, [
       {:eex, "add_triggers.ex", migration_path},
     ]
  end
end