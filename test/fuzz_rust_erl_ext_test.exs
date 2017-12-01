defmodule FuzzRustErlExtTest do
  use ExUnit.Case
  use PropCheck

  property "fuzz", [] do
    gen =
      oneof(
        [
          # FIXME produces invalid utf8 atoms: atom(),
          binary(),
          bitstring(),
          float(),
          integer(),
          non_empty(list(integer())),
          char_list(),
          map_gen(integer(), binary()),
        ]
      )

    numtests(
      1_000_000,
      forall x <- gen do
        port = FuzzRustErlExt.connect
        FuzzRustErlExt.send(port, x)
        result = FuzzRustErlExt.recv(port, 5_000)
        FuzzRustErlExt.disconnect(port)
        equals({:ok, x}, result)
      end
    )
  end

  defp map_gen(key_gen, value_gen) do
    let kvs <- non_empty(list({key_gen, value_gen})) do
      Enum.into(%{}, kvs)
    end
  end
end
