defmodule DennisMenace do
  @moduledoc """
  Once you introduce Dennis and Mr. Wilson and tell Dennis to go play, they'll
  go back and forth forever.

  If you send Ruff in to drag Dennis away, he'll finally stop.

  ```
  iex(1)>  DennisMenace.go
  Mr. Wilson, this is Dennis.
  How do you do?
  Dennis, this is Mr. Wilson.
  Hi there!
  Oh Mr. Wilson!
  Go away!
  Oh Mr. Wilson!
  Go away!
  Oh Mr. Wilson!
  Go away!
  ...
  Put me down Ruff!
  :ok
  ```
  
  """

  def go do
    {:ok, wilson} = GenServer.start_link(MrWilson, :ok)
    {:ok, dennis} = GenServer.start_link(Dennis, :ok)

    IO.puts "Mr. Wilson, this is Dennis."
    GenServer.cast(wilson, {:introduce, dennis})
    :timer.sleep(500)
    IO.puts "Dennis, this is Mr. Wilson."
    GenServer.cast(dennis, {:introduce, wilson})
    :timer.sleep 1000
    GenServer.cast(dennis, :go_play)
    :timer.sleep(2000)
    GenServer.cast(dennis, :dragged_away_by_ruff)
  end
end

defmodule MrWilson do
  use GenServer

  def handle_cast(:annoy, dennis) do
    IO.puts "Go away!"
    GenServer.cast(dennis, :go_play)
    {:noreply, dennis}
  end

  def handle_cast({:introduce, dennis}, _) do
    IO.puts "How do you do?"
    {:noreply, dennis}
  end
end

defmodule Dennis do
  use GenServer

  def handle_cast(:go_play, wilson) do
    IO.puts "Oh Mr. Wilson!"
    GenServer.cast(wilson, :annoy)
    {:noreply, wilson}
  end

  def handle_cast({:introduce, wilson}, _) do
    IO.puts "Hi there!"
    :timer.sleep(100)
    {:noreply, wilson}
  end

  def handle_cast(:dragged_away_by_ruff, wilson) do
    IO.puts "Put me down Ruff!"
    {:stop, :normal, wilson}
  end
end