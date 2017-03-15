defmodule EagerLazyParallel do

    def eager() do
      File.read!("plwiki-20170301-all-titles")
        |> String.split("\n")
           |> Enum.flat_map(&String.split/1)
           |> Enum.reduce(%{}, fn word, map ->
                                    Map.update(map, word, 1, & &1 + 1)
                               end
                         )
    end

    def lazy() do
      File.stream!("plwiki-20170301-all-titles", [], :line)
        |> Stream.flat_map(&String.split/1)
        |> Enum.reduce(%{}, fn word, map ->
                                Map.update(map, word, 1, & &1 + 1)
                            end
                      )
    end

    def parallel() do
      File.stream!("plwiki-20170301-all-titles")
        |> Flow.from_enumerable()
        |> Flow.flat_map(&String.split/1)
        |> Flow.partition()
        |> Flow.reduce(fn -> %{} end, fn word, map ->
                                         Map.update(map, word, 1, & &1 + 1)
                                      end
                        )
        |> Enum.into(%{})
    end


end
