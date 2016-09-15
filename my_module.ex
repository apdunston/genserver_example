defmodule MyModule do
  @moduledoc """
  """
  use GenServer

  @moduledoc """
    Server state for `MyModule`.
    - my_var: a variable
  """
  defmodule State do
    defstruct my_var: nil
  end

  ############################
  ## Client API
  ############################
  def start_link(environment_token, riak_pid) do
    GenServer.start_link(__MODULE__, %State{my_var: nil})
  end

  def do_something(pid, my_arg),
    do: GenServer.call(pid, {:do_something, my_arg})

  ############################
  ## GenServer callbacks
  ############################
  def handle_call({:do_something, my_arg}, _from, state) do
    retval = do_do_something(my_arg)
    {:reply, retval, state}
  end

  ############################
  ## Private functions
  ############################  
  defp do_do_something(my_arg) do
    {:something, my_arg}
  end
  
end
