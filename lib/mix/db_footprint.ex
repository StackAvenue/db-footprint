defmodule Mix.DbFootprint do
  def generator_paths do
    [".", :db_footprint]
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

  def context_base(ctx_app) do
    app_base(ctx_app)
  end

  def new_copy_from(apps, source_dir, binding, mapping) when is_list(mapping) do
    roots = Enum.map(apps, &to_app_source(&1, source_dir))

    for {format, source_file_path, target} <- mapping do
      source =
        Enum.find_value(roots, fn root ->
          source = Path.join(root, source_file_path)
          if File.exists?(source), do: source
        end) || raise "could not find #{source_file_path} in any of the sources"

      case format do
        :text -> Mix.Generator.create_file(target, File.read!(source))
        :eex  -> Mix.Generator.create_file(target, EEx.eval_file(source, tables: binding))
        :new_eex ->
          if File.exists?(target) do
            :ok
          else
            Mix.Generator.create_file(target, EEx.eval_file(source, tables: binding))
          end
      end
    end
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

  @spec camelize(String.t) :: String.t
  def camelize(value), do: Macro.camelize(value)

  @spec camelize(String.t, :lower) :: String.t
  def camelize("", :lower), do: ""
  def camelize(<<?_, t :: binary>>, :lower) do
    camelize(t, :lower)
  end
  def camelize(<<h, _t :: binary>> = value, :lower) do
    <<_first, rest :: binary>> = camelize(value)
    <<to_lower_char(h)>> <> rest
  end

  def print_shell_instructions() do
    Mix.shell.info """
      Remember to update your repository by running migrations:
          $ mix ecto.migrate
      """
  end

  def timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: << ?0, ?0 + i >>
  defp pad(i), do: to_string(i)

  defp app_base(app) do
    case Application.get_env(app, :namespace, app) do
      ^app -> app |> to_string |> camelize()
      mod  -> mod |> inspect()
    end
  end

  defp to_lower_char(char) when char in ?A..?Z, do: char + 32
  defp to_lower_char(char), do: char

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