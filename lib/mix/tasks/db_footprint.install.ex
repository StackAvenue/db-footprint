defmodule Mix.Tasks.DbFootprint.Install do
  use Mix.Task

  @shortdoc "Track changes to your models, for auditing or versioning"

  @moduledoc """
    This is where we would put any long form documentation or doctests.
  """

  def run(_args) do
    Mix.DbFootprint.generator_paths()
      |> copy_new_files()
    print_shell_instructions()
  end

  def copy_new_files(paths) do
    #arg_1 = "ctx_app: discuss" (directory or project where this needs to be set up i.e root element of the project)
    #arg_2 = "rel_path: priv/repo/migrations/1567101445_create_versions.exs"
    migration_path = Mix.DbFootprint.context_app_path(Mix.Project.config[:app], "priv/repo/migrations/#{timestamp()}_create_versions.exs")

    #migration_path = "priv/repo/migrations/1567101445_create_versions.exs"
    #IO.inspect("-------------------")
    #IO.inspect migration_path
    #arg_1 = paths: [".", :db_footprint]
    #arg_2 = "source_dir: priv/templates/db_footprint.install"
    #arg_3 = "binding: "
    #arg_4 = "[{:eex, "create_versions.ex", "priv/repo/migrations/1567101445_create_versions.exs"}]"

    Mix.DbFootprint.copy_from paths, "priv/templates/db_footprint.install", [], [
       {:eex, "create_versions.ex", migration_path},
     ]
  end

  def print_shell_instructions() do
    Mix.shell.info """
      Remember to update your repository by running migrations:
          $ mix ecto.migrate
      """
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end
  defp pad(i) when i < 10, do: << ?0, ?0 + i >>
  defp pad(i), do: to_string(i)
end