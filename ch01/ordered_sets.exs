unique_emails = :ordsets.new()

unique_emails = :ordsets.add_element("jane@gmail.com", unique_emails)

unique_emails = :ordsets.add_element("meraj@gmail.com", unique_emails)

:ordsets.to_list(unique_emails)

:ordsets.is_element("meraj@gmail.com", unique_emails)

unique_emails = :ordsets.del_element("meraj@gmail.com", unique_emails)

unique_emails
