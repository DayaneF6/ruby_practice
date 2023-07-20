
def get_teacher(id, client)
  f = "select first_name, middle_name, last_name, birth_date from teachers_dayane where ID = #{id}"
  results = client.query(f).to_a
  if results.count.zero?
    puts "Teacher with ID #{id} was not found."
  else
    puts "Teacher #{results[0]['first_name']} #{results[0]['middle_name']} #{results[0]['last_name']} was born on #{(results[0]['birth_date']).strftime("%d %b %Y (%A)")}"
  end
end

def get_subject_teachers(subject_id, client)
  # Get subject name
  subject_query = "SELECT name FROM subjects_dayane WHERE ID = #{id}"
  subject_result = client.query(subject_query).to_a

  if subject_result.empty?
    puts "Subject with ID #{id} was not found."
    return
  end

  subject_name = subject_result[0]['subject_name']

  # Get teachers for the subject
  teachers_query = "SELECT t.first_name, t.middle_name, t.last_name FROM teachers_dayane t JOIN subjects_dayane st ON t.ID = st.teacher_id WHERE st.id = #{id}"
  teachers_result = client.query(teachers_query).to_a

  if teachers_result.empty?
    puts "No teachers found for subject with ID #{id}."
    return
  end

  puts "Subject: #{subject_name}"
  puts "Teachers:"

  teachers_result.each do |teacher|
    puts "#{teacher['first_name']} #{teacher['middle_name']} #{teacher['last_name']}"
  end
end
