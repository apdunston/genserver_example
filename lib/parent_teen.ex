defmodule ParentTeen do
  @moduledoc """
  Parent asks the teen if the baby is okay. Teen can't answer until the baby
  says its okay. Baby takes a couple of seconds. How does the teen handle this?

  Teen answers `handle_call` with `:noreply` but keeps the `from` in `state`.
  When teen gets the `handle_cast` from the baby, it does a `reply` to the 
  `from` in its state.

  If the baby takes > 5 sec, then the call from parent to teen will time out.
  But this provides a way for the teen to stop executing the handle_call while
  it's waiting for the baby to buzz in.

  ```
  iex(1)> ParentTeen.go
  Goo goo?
  Is the baby okay?
  Tell you in a minute.
  Gah gah :)
  Yes, the baby's fine.
  :ok
  ```
  """

  def go do
    {:ok, teen} = Teen.start_link
    {:ok, baby} = GenServer.start_link(Baby, :ok)
    {:ok, parent} = GenServer.start_link(Parent, teen)
    GenServer.cast(baby, {:say_youre_fine_in_a_couple_seconds, teen})
    IO.puts GenServer.call(parent, :is_the_baby_okay)
  end
end

defmodule Parent do
  use GenServer

  def handle_call(:is_the_baby_okay, _from, state) do
    IO.puts "Is the baby okay?"
    {:reply, GenServer.call(state, :is_the_baby_okay), state}
  end

end


defmodule Teen do
  use GenServer

  def start_link,
    do: GenServer.start_link(__MODULE__, %{baby_good: false, parent_from: nil})

  def handle_call(:is_the_baby_okay, _from, %{baby_good: true} = state) do
    {:reply, "yes", state}
  end

  def handle_call(:is_the_baby_okay, from, _state) do   
    IO.puts "Tell you in a minute." 
    {:noreply, %{parent_from: from, baby_good: false}}
  end


  def handle_cast(:im_fine, %{parent_from: nil}), 
    do: {:noreply, %{baby_good: true, parent_from: nil}}

  def handle_cast(:im_fine, %{parent_from: from}) do
    GenServer.reply(from, "Yes, the baby's fine.")
    {:noreply, %{parent_from: nil, baby_good: true}}
  end

end

defmodule Baby do
  use GenServer

  def handle_cast({:say_youre_fine_in_a_couple_seconds, teen}, state) do
    IO.puts "Goo goo?"
    :timer.sleep 2000
    IO.puts "Gah gah :)"
    GenServer.cast(teen, :im_fine)
    {:noreply, state}
  end
end