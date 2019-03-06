defmodule StuartClientElixirTest.QueueTest do
  use ExUnit.Case

  alias StuartClientElixir.Queue

  test "unqueue on an empty queue should return nil" do
    assert nil == Queue.unqueue()
  end

  test "unqueue on a queue will one item should return the item" do
    # given
    enqueued_value = :test
    Queue.enqueue(enqueued_value)

    # when
    unqueued_value = Queue.unqueue()

    # then
    assert enqueued_value == unqueued_value
  end

  test "unqueue items first in first out" do
    # given
    Queue.enqueue(:first)
    Queue.enqueue(:second)

    # when
    first = Queue.unqueue
    second = Queue.unqueue

    # then
    assert first == :first
    assert second == :second
  end
end
