defmodule Mix.Tasks.DbFootprint.AddTrigger do
	use Mix.Task

	@shortdoc "Add Triggers to the provided modules"

	def run(_args) do
		Mix.DbFootprint.generator_paths()
      |> copy_new_files()
    print_shell_instructions()
  end

  def copy_new_files(paths) do
    migration_path = Mix.DbFootprint.context_app_path(Mix.Project.config[:app], "priv/repo/migrations/#{timestamp()}_add_triggers.exs")

    Mix.DbFootprint.copy_from paths, "priv/templates/db_footprint.install", [], [
       {:eex, "add_triggers.ex", migration_path},
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