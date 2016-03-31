defmodule B do
  use GenServer

  # What would happen if we could spawn multiple processes
  # of module B with arbitrary names?
  #
  # The result would be a spectacular crash because
  # registering a table with the same name would throw
  # an error, preventing MOD.init callback to return
  # with the initial state of the GenServer process.
  #
  # ** (EXIT from #PID<0.103.0>) an exception was raised:
  #     ** (ArgumentError) argument error
  #         (stdlib) :ets.new(:lofa, [:named_table])
  #         /home/toraritte/zenith-and-quazar/scientific_breakthrough_of_the_afternoon/elixir/ets_genserver_test.ex:41: B.init/1
  #         (stdlib) gen_server.erl:328: :gen_server.init_it/6
  #         (stdlib) proc_lib.erl:240: :proc_lib.init_p_do_apply/3

  # client
  # BEWARE: B.start_link/1 now accepts an atom
  #         as an id for the process
  def start_link(proc_name) do
    # This doesn't seem to work
    #   state = :ets.new(:lofa, [:named_table])
    #   GenServer.start_link(@this, state, name: @this)
    GenServer.start_link(__MODULE__, :ok, name: proc_name)
  end

  def add(proc_name, key, value) do
    GenServer.call(proc_name, {:add, key, value})
  end

  def check_state?(proc_name) do
    GenServer.call(proc_name, :state)
  end

  def stop(proc_name), do: GenServer.stop(proc_name)

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

# How to turn this into an app? So that module B is started with iex.
