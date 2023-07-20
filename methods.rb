
def get_teacher(id, client)
  f = "select first_name, middle_name, last_name, birth_date from teachers_dayane where ID = #{id}"
  results = client.query(f).to_a
  if results.count.zero?
    puts "Teacher with ID #{id} was not found."
  else
    puts "Teacher #{results[0]['first_name']} #{results[0]['middle_name']} #{results[0]['last_name']} was born on #{(results[0]['birth_date']).strftime("%d %b %Y (%A)")}"
  end
end

def get_subject_teachers(id, client)
  c = "SELECT s.name, t.first_name, t.middle_name, t.last_name FROM subjects_dayane s
       JOIN teachers_dayane t ON t.id = s.id WHERE s.id = \"#{id}\""
  results = client.query(c).to_a

  if results.empty?
    p "Subject with ID #{id} was not found."
  else
    p "Subject #{results[0]['name']} - Teacher #{results[0]['first_name']} #{results[0]['middle_name']} #{results[0]['last_name']}"
  end
end

=begin def get_subject_teachers(id, client)
  # Get subject name
  subject_query = "SELECT name FROM subjects_dayane WHERE ID = #{id}"
  subject_result = client.query(subject_query).to_a
  if subject_result.empty?
    p "Subject with ID #{id} was not found."
    return
  end
  name = subject_result[0]['name']
  # Get teachers for the subject
  teachers_query = "SELECT t.first_name, t.middle_name, t.last_name FROM teachers_dayane t JOIN subjects_dayane st ON t.ID = st.id WHERE st.id = #{id}"
  teachers_result = client.query(teachers_query).to_a
  if teachers_result.empty?
    p "No teachers found for subject with ID #{id}."
    return
  end
  p "Subject: #{name}"
  p "Teachers:"
  teachers_result.each do |teacher|
    p "#{teacher['first_name']} #{teacher['middle_name']} #{teacher['last_name']}"
  end
end
=end

def get_class_subjects(name, client)
    c = "SELECT c.name, td.first_name, td.middle_name, td.last_name FROM classes_dayane c
         JOIN teachers_dayane td ON td.id = c.responsible_teacher_id WHERE name = \"#{name}\""
    results = client.query(c).to_a

    if results.empty?
      p "Class with name #{name} was not found."
    else
      p "Class #{results[0]['name']} - Teacher #{results[0]['first_name']} #{results[0]['middle_name']} #{results[0]['last_name']}"
    end
end

def get_teachers_list_by_letter(letter1, letter2, client)
  tl = "SELECT s.name, t.first_name, t.middle_name, t.last_name FROM teachers_dayane t
        JOIN subjects_dayane s ON t.id = s.id WHERE t.first_name
        LIKE '%#{letter1}%' AND t.last_name LIKE '%#{letter2}%'"

  results = client.query(tl).to_a

  if results.empty?
    p "Teacher with name #{letter1} #{letter1}  was not found."
  else
    p "Teacher #{results[0]['first_name']} #{results[0]['middle_name']} #{results[0]['last_name']} - Subject #{results[0]['name']} - "
  end
end

