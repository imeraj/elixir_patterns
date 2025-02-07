unique_emails = :array.new()

unique_emails = :array.set(0, "jane@gmail.com", unique_emails)

unique_emails = :array.set(1, "meraj@gmail.com", unique_emails)

:array.to_list(unique_emails)

:array.get(0, unique_emails)

:array.get(1, unique_emails)
