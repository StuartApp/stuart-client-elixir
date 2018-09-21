defmodule StuartClientElixir.Infrastructure.Queue do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :queue.new(), name: :stuart_queue)
  end

  def init(queue) do
    {:ok, queue}
  end

  def enqueue(item), do: GenServer.cast(:stuart_queue, {:enqueue, item})

  def unqueue(), do: GenServer.call(:stuart_queue, :unqueue)

  #############
  # Callbacks #
  #############

  def handle_call(:unqueue, _from, queue) do
    {item, q} = :queue.out(queue)

    case item do
      {:value, value} -> {:reply, value, q}
      :empty -> {:reply, nil, q}
    end
  end

  def handle_cast({:enqueue, item}, queue), do: {:noreply, :queue.in(item, queue)}
end
