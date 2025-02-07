my_workflow = :digraph.new([:acyclic])

do_work = fn step ->
  fn ->
    IO.puts("Running the following step: " <> step)

    # Simulate load
    Process.sleep(500)
  end
end

:digraph.add_vertex(my_workflow, :create_user, do_work.("Create user in database"))
:digraph.add_vertex(my_workflow, :upload_avatar, do_work.("Upload image to S3"))
:digraph.add_vertex(my_workflow, :charge_card, do_work.("Bill credit card"))
:digraph.add_vertex(my_workflow, :welcome_email, do_work.("Send welcome email"))

:digraph.add_edge(my_workflow, :create_user, :upload_avatar)
:digraph.add_edge(my_workflow, :create_user, :charge_card)
:digraph.add_edge(my_workflow, :upload_avatar, :welcome_email)
:digraph.add_edge(my_workflow, :charge_card, :welcome_email)

:digraph.info(my_workflow)
:digraph.source_vertices(my_workflow)
:digraph.sink_vertices(my_workflow)
:digraph_utils.is_acyclic(my_workflow)

my_workflow
|> :digraph_utils.topsort()
|> Enum.each(fn vertex ->
  {_vertex, work_function} = :digraph.vertex(my_workflow, vertex)
  work_function.()
end)

:digraph.delete(my_workflow)
