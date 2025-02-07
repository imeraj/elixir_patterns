unique_emails = :sets.new(version: 2)

unique_emails = :sets.add_element("jane@gmail.com", unique_emails)

unique_emails = :sets.add_element("meraj@gmail.com", unique_emails)

:sets.to_list(unique_emails)

:sets.is_element("meraj@gmail.com", unique_emails)

unique_emails = :sets.del_element("meraj@gmail.com", unique_emails)

unique_emails
