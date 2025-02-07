:persistent_term.get()

:persistent_term.put({:my_app, :my_key}, %{some: "Data", that: "Rarely", ever: "Changes"})

{:my_app, :my_key}
|> :persistent_term.get()
|> Map.fetch!(:some)
