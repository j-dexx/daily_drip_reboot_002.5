defmodule Rpn do
  @moduledoc """
  Documentation for Rpn.
  """

  def start do
    { :ok, spawn(__MODULE__, :loop, [[]]) }
  end

  def loop(stack) do
    # We'll receive a message from another process, with a ref, and the atom
    # `peek`. We will then send back a 2-tuple containing the ref they sent
    # and the value of our stack.
    receive do
      { from, ref, :peek } ->
        send(from, { ref, stack })
        loop(stack)

      { :push, :+ } ->
        [second | [ first | rest ]] = stack
        loop([first + second | rest])

      { :push, :- } ->
        [second | [ first | rest ]] = stack
        loop([first - second | rest])

      { :push, :x } ->
        [second | [ first | rest ]] = stack
        loop([first * second | rest])

      { :push, val } -> loop([val | stack])
    end
  end

  # We'll provide a function that makes it easy to send the message the loop is
  # waiting for and then enters a receive loop of its own, awaiting a reply. The
  # reason we make these unique references, by the way, is because anyone could
  # send us a message at any time, and if it matched the pattern we were looking
  # for we would accept it - this way we only match the message we're hoping to
  # get back.
  def peek(pid) do
    ref = make_ref()
    send(pid, { self(), ref, :peek })
    receive do
      { ^ref, val } -> val
    end
  end

  def push(pid, val) do
    send(pid, { :push, val })
  end

end
