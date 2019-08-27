defmodule Mix.Tasks.DbFootprint.Install do
	use Mix.Task

	@shortdoc "Track changes to your models, for auditing or versioning"

	@moduledoc """
    This is where we would put any long form documentation or doctests.
  """

  def run(_args) do
  	paths = Mix.Phoenix.generator_paths()

  	copy_new_files(paths)
  	print_shell_instructions()
  end

  def copy_new_files(paths) do
  	migration_path = Mix.Phoenix.context_app_path(:db_footprint, "priv/repo/migrations/#{timestamp()}_create_versions.exs")
  	
  	Mix.Phoenix.copy_from paths, "priv/templates/db_footprint.install.create_versions", binding(), [
       {:eex, "migration.exs", migration_path},
     ]
  end

  def print_shell_instructions() do
  	Mix.shell.info """
      Remember to update your repository by running migrations:
          $ mix ecto.migrate
      """
  end

  def timestamp do
  	:os.system_time(:seconds)
	end
end