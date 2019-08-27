defmodule Mix.Phoenix do
	def generator_paths do
    [".", :phoenix]
  end

  def context_app_path(ctx_app, rel_path) when is_atom(ctx_app) do
    this_app = otp_app()

    if ctx_app == this_app do
      rel_path
    else
      app_path =
        case Application.get_env(this_app, :generators)[:context_app] do
          {^ctx_app, path} -> Path.relative_to_cwd(path)
          _ -> mix_app_path(ctx_app, this_app)
        end
      Path.join(app_path, rel_path)
    end
  end

  def otp_app do
    Mix.Project.config |> Keyword.fetch!(:app)
  end

  def copy_from(apps, source_dir, binding, mapping) when is_list(mapping) do
    roots = Enum.map(apps, &to_app_source(&1, source_dir))

    for {format, source_file_path, target} <- mapping do
      source =
        Enum.find_value(roots, fn root ->
          source = Path.join(root, source_file_path)
          if File.exists?(source), do: source
        end) || raise "could not find #{source_file_path} in any of the sources"

      case format do
        :text -> Mix.Generator.create_file(target, File.read!(source))
        :eex  -> Mix.Generator.create_file(target, EEx.eval_file(source, binding))
        :new_eex ->
          if File.exists?(target) do
            :ok
          else
            Mix.Generator.create_file(target, EEx.eval_file(source, binding))
          end
      end
    end
  end

  defp to_app_source(path, source_dir) when is_binary(path),
    do: Path.join(path, source_dir)
  defp to_app_source(app, source_dir) when is_atom(app),
    do: Application.app_dir(app, source_dir)

  defp mix_app_path(app, this_otp_app) do
    case Mix.Project.deps_paths() do
      %{^app => path} ->
        Path.relative_to_cwd(path)
      deps ->
        Mix.raise """
        no directory for context_app #{inspect app} found in #{this_otp_app}'s deps.
        Ensure you have listed #{inspect app} as an in_umbrella dependency in mix.exs:
            def deps do
              [
                {:#{app}, in_umbrella: true},
                ...
              ]
            end
        Existing deps:
            #{inspect Map.keys(deps)}
        """
    end
  end
end