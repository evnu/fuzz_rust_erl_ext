defmodule FuzzRustErlExt do
  @moduledoc """
  Documentation for FuzzRustErlExt.
  """

  @doc """
  Connect to `echo`.
  """
  def connect do
    path = "priv/echo-rust/target/release/echo"
    args = [
      :binary,
      env: [{'RUST_BACKTRACE', '1'}],
    ]
    Port.open({:spawn_executable, path}, args)
  end

  @doc """
  Disconnect from `echo`.
  """
  def disconnect(port) do
    Port.close(port)
  catch
    _ -> :ok
  end

  @doc """
  Send a term to `echo`.
  """
  def send(port, term) do
    Port.command(port, :erlang.term_to_binary(term))
  end

  @doc """
  Receive and convert.
  """
  def recv(port, timeout) do # -> {:ok, term} | :timeout
    recv(port, timeout, <<>>)
  end

  def recv(_, remaining_timeout, _acc) when remaining_timeout <= 0 do
    :timeout
  end
  def recv(port, remaining_timeout, acc) do
    {time_us, acc} = :timer.tc(fn ->
        receive do
          {^port, {:data, data}} ->
            acc <> data
        after remaining_timeout ->
          :timeout
        end
    end)

    try do
      {:ok, :erlang.binary_to_term(acc)}
    rescue
      _ ->
        remaining_timeout = remaining_timeout - div(time_us, 1_000)
        recv(port, remaining_timeout, acc)
    end
  end
end
