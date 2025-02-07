my_queue = :queue.new()

my_queue = :queue.in(1, my_queue)

my_queue = :queue.in(2, my_queue)

{{:value, my_value}, my_queue} = :queue.out(my_queue)

{{:value, my_value}, my_queue} = :queue.out(my_queue)

{:empty, my_queue} = :queue.out(my_queue)
