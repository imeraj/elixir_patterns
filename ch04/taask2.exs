opts = %{
  total_requests: 200,
  concurrency: 10,
  url: ~c"https://news.google.com"
}

:inets.start()
:ssl.start()

1..opts.total_requests
|> Task.async_stream(
  fn _ ->
    start_time = System.monotonic_time()
    :httpc.request(:get, {opts.url, []}, [], [])
    System.monotonic_time() - start_time
  end,
  max_concurrency: opts.concurrency
)
|> Enum.reduce(0, fn {:ok, req_time}, acc -> acc + req_time end)
|> System.convert_time_unit(:native, :millisecond)
|> Kernel./(opts.total_requests)
