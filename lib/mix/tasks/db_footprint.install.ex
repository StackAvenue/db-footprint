defmodule Mix.Tasks.DbFootprint.Install do
  use Mix.Task
  alias Mix.DbFootprint

  @shortdoc "Track changes to your models, for auditing or versioning"

  @moduledoc """
    This is where we would put any long form documentation or doctests.
  """

  def run(_args) do
    DbFootprint.generator_paths()
      |> copy_new_files()
    DbFootprint.print_shell_instructions()
  end

  def copy_new_files(paths) do
    #arg_1 = "ctx_app: discuss" (directory or project where this needs to be set up i.e root element of the project)
    #arg_2 = "rel_path: priv/repo/migrations/1567101445_create_versions.exs"

    migration_path = DbFootprint.context_app_path(Mix.Project.config[:app], "priv/repo/migrations/#{DbFootprint.timestamp()}_create_versions.exs")
    version_schema_path = DbFootprint.context_app_path(Mix.Project.config[:app], "lib/#{Atom.to_string(Mix.Project.config[:app])}/version.ex")

    #migration_path = "priv/repo/migrations/1567101445_create_versions.exs"
    #IO.inspect("-------------------")
    #IO.inspect migration_path
    #arg_1 = paths: [".", :db_footprint]
    #arg_2 = "source_dir: priv/templates/db_footprint.install"
    #arg_3 = "binding: "
    #arg_4 = "[{:eex, "create_versions.ex", "priv/repo/migrations/1567101445_create_versions.exs"}]"

    DbFootprint.copy_from paths, "priv/templates/db_footprint.install", [], [
       {:eex, "create_versions.ex", migration_path},
     ]

    DbFootprint.copy_from paths, "priv/templates/db_footprint.install", [DbFootprint.context_base(Mix.Project.config[:app])], [
       {:eex, "version.ex", version_schema_path},
     ]
  end
end