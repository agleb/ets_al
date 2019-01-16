defmodule EtsAl.Keeper do
  use GenServer
  require Forensic

  @moduledoc """
  ETS Abstraction Layer
  Generic abstraction layer for ETS operations.

  Acts as an assets holder for ETS tables to let them survive crashes.

  Should be started under the App's supervisor.
  """

  ### GenServer callbacks
  @doc false
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc false
  def init(state) do
    {:ok, state}
  end

  ### API for Table manipulation

  @doc """
  Return info for the table
  """
  def table_info(table_id) when is_atom(table_id), do: :ets.info(table_id)

  def table_info(_table_id), do: Forensic.error(:invalid_params)

  @doc """
  Create a table under the Keeper's PID (ownership)
  """
  def create_table(table_id, table_spec) when is_atom(table_id) and is_list(table_spec) do
    GenServer.call(__MODULE__, {:create_table, table_id, table_spec})
  end

  def create_table(_table_id, _table_spec),
    do: Forensic.error(:invalid_params)

  def create_public_set(table_id) when is_atom(table_id) do
    create_table(table_id, [:set, :public, :named_table, read_concurrency: true])
  end

  def create_public_set(_table_id),
    do: Forensic.error(:invalid_params)

  def create_public_ordered_set(table_id) when is_atom(table_id) do
    create_table(table_id, [:ordered_set, :public, :named_table, read_concurrency: true])
  end

  def create_public_ordered_set(_table_id),
    do: Forensic.error(:invalid_params)

  def create_public_bag(table_id) when is_atom(table_id) do
    create_table(table_id, [:bag, :public, :named_table, read_concurrency: true])
  end

  def create_public_bag(table_id),
    do: Forensic.error( :invalid_params)

  @doc """
  Clear a table under the Keeper's PID (ownership)
  """
  def clear_table(table_id) when is_atom(table_id) do
    GenServer.call(__MODULE__, {:clear_table, table_id})
  end

  def clear_table(_table_id),
    do: Forensic.error(:invalid_params)

  @doc """
  Delete a table under the Keeper's PID (ownership)
  """
  def delete_table(table_id) when is_atom(table_id) do
    GenServer.call(__MODULE__, {:delete_table, table_id})
  end

  def delete_table(_table_id),
    do: Forensic.error(:invalid_params)

  @doc """
  List tables under the Keeper's PID (ownership)
  """
  def list_tables() do
    GenServer.call(__MODULE__, {:list_tables})
  end

  @doc """
  Dump table contents to the list
  """
  def tab2list(table_id) when is_atom(table_id) do
    case table_exists?(table_id) do
      true -> {:ok, :ets.tab2list(table_id)}
      false -> Forensic.error(:table_not_exists)
    end
  end

  def tab2list(_table_id),
    do: Forensic.error(:invalid_params)

  @doc """
  Read a table from the dump and create it under the Keeper's PID (ownership)
  """
  def file2tab(table_id, file_path) when is_atom(table_id) and is_binary(file_path) do
    GenServer.call(__MODULE__, {:file2tab, file_path, table_id})
  end

  def file2tab(_table_id, _file_path),
    do: Forensic.error(:invalid_params)

  @doc """
  Dump a table
  """
  def tab2file(table_id, file_path) when is_atom(table_id) and is_binary(file_path) do
    GenServer.call(__MODULE__, {:tab2file, file_path, table_id})
  end

  def tab2file(_table_id, _file_path),
    do: Forensic.error(:invalid_params)

  ### Consumer API functions

  @doc """
  Insert a key in the ETS table.

  Returns:

  {:ok, true} on success,

  Forensic.error(description) in case of error.
  """
  def insert(table_id, key, values)
      when is_atom(table_id) and not is_nil(key) and is_list(values) do
    try do
      {:ok, :ets.insert(table_id, List.to_tuple([key] ++ values))}
    rescue
      e -> Forensic.error(e)
    end
  end

  def insert(_table_id, _key, _values),
    do: Forensic.error(:invalid_params)

  @doc """
  Update a key in the ETS table.

  Returns:

  {:ok, true} on success,

  {:ok, false} if key does not exists in the table,

  Forensic.error(description) in case of error.
  """

  def update(table_id, key, values)
      when is_atom(table_id) and not is_nil(key) and is_list(values) do
    case key_exists?(table_id, key) do
      {:ok, true} -> insert(table_id, key, values)
      {:ok, false} -> {:ok, false}
      error -> error
    end
  end

  def update(_table_id, _key, _values),
    do: Forensic.error(:invalid_params)

  @doc """
  Insert new key into the ETS table.

  Returns:

  {:ok, true} on success,

  {:ok, false} if key already exists,

  Forensic.error(description) in case of error.
  """
  def insert_new(table_id, key, values)
      when is_atom(table_id) and not is_nil(key) and not is_list(key) and is_list(values) do
    try do
      {:ok, :ets.insert_new(table_id, List.to_tuple([key] ++ values))}
    rescue
      e -> Forensic.error(e)
    end
  end

  def insert_new(_table_id, _key, _values),
    do: Forensic.error(:invalid_params)

  def delete(table_id, key)
      when is_atom(table_id) and not is_nil(key) do
    try do
      {:ok, :ets.delete(table_id, key)}
    rescue
      e -> Forensic.error(e)
    end
  end

  def delete(_table_id, _key),
    do: Forensic.error(:invalid_params)

  def key_exists?(table_id, key)
      when is_atom(table_id) and not is_nil(key) do
    try do
      :ets.member(table_id, key)
    rescue
      e -> Forensic.error(e)
    end
  end

  def key_exists?(_table_id, _key),
    do: Forensic.error(:invalid_params)

  def fetch(table_id, key)
      when is_atom(table_id) and not is_nil(key) do
    try do
      {:ok, List.first(:ets.lookup(table_id, key))}
    rescue
      e -> Forensic.error(e)
    end
  end

  def fetch(_table_id, _key),
    do: Forensic.error(:invalid_params)

  def fetch_range(table_id, start_key, limit)
      when is_atom(table_id) and not is_nil(start_key) and is_integer(start_key) and
             start_key >= 0 and is_integer(limit) and limit > 0 do
    with true <- table_exists?(table_id),
         {:ok, true} <- key_exists?(table_id, start_key),
         {:ok, start_acc} <- fetch(table_id, start_key) do
      {:ok, fetch_next_recursive(table_id, start_key, [start_acc], limit - 1)}
    else
      error -> Forensic.error(error)
    end
  end

  def fetch_range(_table_id, _start_key, _limit),
    do: Forensic.error(:invalid_params)

  defp fetch_next_recursive(table_id, key, acc, limit) do
    with {:ok, next_key} when next_key != nil <- next(table_id, key),
         value when is_list(value) <- :ets.lookup(table_id, next_key),
         next_acc <- acc ++ value,
         true <- limit > 0 do
      fetch_next_recursive(table_id, next_key, next_acc, limit - 1)
    else
      _ -> acc
    end
  end

  defp next(table_id, key)
       when is_atom(table_id) and not is_nil(key) do
    try do
      case :ets.next(table_id, key) do
        :"$end_of_table" -> {:ok, nil}
        key -> {:ok, key}
      end
    rescue
      e -> Forensic.error(e)
    end
  end

  def select(table_id, match_spec) when is_atom(table_id) do
    case table_exists?(table_id) do
      true -> {:ok, :ets.select(table_id, match_spec)}
      false -> Forensic.error(:table_not_exists)
    end
  end

  def select(_table_id, _match_spec),
    do: Forensic.error(:invalid_params)

  def select(table_id, match_spec, limit)
      when is_atom(table_id) and is_integer(limit) and limit > 0 do
    case table_exists?(table_id) do
      true -> {:ok, :ets.select(table_id, match_spec, limit)}
      false -> Forensic.error(:table_not_exists)
    end
  end

  def select(_table_id, _match_spec, _limit),
    do: Forensic.error(:invalid_params)

  def select_delete(table_id, match_spec) when is_atom(table_id) do
    case table_exists?(table_id) do
      true -> {:ok, :ets.select_delete(table_id, match_spec)}
      false -> Forensic.error(:table_not_exists)
    end
  end

  def select_delete(_table_id, _match_spec),
    do: Forensic.error(:invalid_params)

  ### GenServer callbacks for API calls

  def handle_call({:create_table, table_id, table_spec}, _from, state) do
    with false <- table_exists?(table_id),
         table_reference <- :ets.new(table_id, table_spec) do
      {:reply, {:ok, table_reference}, state ++ [table_id]}
    else
      error -> {:reply, Forensic.error(error), state}
    end
  end

  def handle_call({:clear_table, table_id}, _from, state) do
    if table_exists?(table_id) do
      :ets.delete_all_objects(table_id)
      {:reply, {:ok, true}, state}
    else
      {:reply,
       Forensic.error(:table_does_not_exist), state}
    end
  end

  def handle_call({:delete_table, table_id}, _from, state) do
    if table_exists?(table_id) do
      :ets.delete(table_id)
      {:reply, {:ok, table_id}, List.delete(state, table_id)}
    else
      {:reply, Forensic.error(table_id), state}
    end
  end

  def handle_call({:list_tables}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:file2tab, file_path, table_id}, _from, state)
      when is_binary(file_path) and is_atom(table_id) do
    path = String.to_charlist(file_path)

    with true <- File.regular?(path),
         false <- table_exists?(table_id),
         {:ok, _} <- :ets.tabfile_info(path),
         {:ok, _} <- :ets.file2tab(path) do
      {:reply, {:ok, table_id}, state ++ [table_id]}
    else
      _error -> {:reply, Forensic.error(table_id), state}
    end
  end

  def handle_call({:file2tab, _path, _table_id}, _from, state) do
    {:reply, Forensic.error(:invalid_params), state}
  end

  def handle_call({:tab2file, file_path, table_id}, _from, state)
      when is_binary(file_path) and is_atom(table_id) do
    case table_exists?(table_id) do
      true ->
        {:reply,
         :ets.tab2file(
           table_id,
           String.to_charlist(file_path)
         ), state ++ [table_id]}

      false ->
        {:reply, Forensic.error(:not_exists), state}
    end
  end

  def table_exists?(table_id) when is_atom(table_id) do
    :ets.info(table_id) != :undefined
  end

  def table_exists?(_table_id) do
    Forensic.error(:invalid_table_id)
  end
end
