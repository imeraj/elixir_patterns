unique_emails = :gb_sets.new()

unique_emails = :gb_sets.add_element("jane@gmail.com", unique_emails)

unique_emails = :gb_sets.add_element("meraj@gmail.com", unique_emails)

:gb_sets.to_list(unique_emails)

:gb_sets.is_element("meraj@gmail.com", unique_emails)

unique_emails = :gb_sets.del_element("meraj@gmail.com", unique_emails)

unique_emails
