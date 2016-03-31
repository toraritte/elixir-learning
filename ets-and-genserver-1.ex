defmodule B do
  use GenServer

  # Passing this attribute to GenServer.start_link/3
  # so that once a process is spawned from this module,
  # it can be referred to as this modules name.
  #
  # (-) Only one instance can be started this way
  #     because the server will be registered under
  #     the module name and if you try starting
  #     another one, register/2 will complain that
  #     there is already a process running with the
  #     same name.
  #     iex> {:error, {:already_started, #PID<0.92.0>}}

  # ===1==
  # What would happen if we could spawn multiple processes
  # of module B with arbitrary names?
  # SEE
  # "ets-and-genserver-with-arbitrary-process-names.ex"

  # ===2==
  # How to modify this file to automatically spawn a
  # process of this module when iex starts up?
  # (Just like in the Elixir guide's "iex -S mix")

  @this __MODULE__

  # client
  def start_link do
    # This doesn't seem to work
    #   state = :ets.new(:lofa, [:named_table])
    #   GenServer.start_link(@this, state, name: @this)
    GenServer.start_link(__MODULE__, :ok, name: @this)
  end

  def add(key, value) do
    GenServer.call(@this, {:add, key, value})
  end

  def check_state? do
    GenServer.call(@this, :state)
  end

  def stop, do: GenServer.stop(@this)

  # server
  def init(:ok) do
    {:ok, :ets.new(:lofa, [:named_table])}
  end

  def handle_call(msg, _from, state) do
    case msg do
      #
      {:add, key, value} ->
      # same as
      # :ets.insert(state, {key, value})
        :ets.insert(:lofa, {key, value})
        {:reply,
        "Added: {key: #{inspect key}, value: #{inspect value}}
          Current state is #{inspect state}",
          :lofa}
      :state ->
        {:reply, {state, :ets.tab2list(state)}, state}
    end
  end
end
