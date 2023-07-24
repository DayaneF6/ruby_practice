require 'digest'


def get_teacher(id, client)
  f = "select first_name, middle_name, last_name, birth_date, s.name from teachers_dayane t JOIN subjects_dayane s ON t.id = s.id WHERE t.id = #{id}"
  results = client.query(f).to_a
  if results.count.zero?
    puts "Teacher with ID #{id} was not found."
  else
    string = "Subject: #{results[0]['name']}\nTeachers:"
    results.each do |row|
      string += "#{row['first_name']} #{row['middle_name']} #{row['last_name']}\n"
    end
    puts string
    #puts "Teacher #{results[0]['first_name']} #{results[0]['middle_name']} #{results[0]['last_name']} was born on #{(results[0]['birth_date']).strftime("%d %b %Y (%A)")}"
  end
end

def get_subject_teachers(id, client)
  c = "SELECT s.name, t.first_name, t.middle_name, t.last_name FROM subjects_dayane s
       JOIN teachers_dayane t ON t.id = s.id WHERE s.id = \"#{id}\""
  results = client.query(c).to_a

  if results.empty?
    p "Subject with ID #{id} was not found."
  else
    string = "Subject: #{results[0]['name']}\nTeachers:"
    results.each do |row|
      string += "#{row['first_name']} #{row['middle_name']} #{row['last_name']}\n"
    end
    puts string
    #p "Subject #{results[0]['name']} - Teacher #{results[0]['first_name']} #{results[0]['middle_name']} #{results[0]['last_name']}"
  end
end

def get_class_subjects(name, client)
    c = "SELECT c.name, td.first_name, td.middle_name, td.last_name FROM classes_dayane c
         JOIN teachers_dayane td ON td.id = c.responsible_teacher_id WHERE name = \"#{name}\""
    results = client.query(c).to_a

    if results.empty?
      p "Class with name #{name} was not found."
    else
      string = "Class: #{results[0]['name']}\nTeachers:"
      results.each do |row|
        string += "#{row['first_name']} #{row['middle_name']} #{row['last_name']}\n"
      end
      puts string
      #p "Class #{results[0]['name']} - Teacher #{results[0]['first_name']} #{results[0]['middle_name']} #{results[0]['last_name']}"
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
    string = "Subject: #{results[0]['name']}\nTeachers:"
    results.each do |row|
      string += "#{row['first_name']} #{row['middle_name']} #{row['last_name']}\n"
    end
    puts string
    #p "Teacher #{results[0]['first_name']} #{results[0]['middle_name']} #{results[0]['last_name']} - Subject #{results[0]['name']} - "
  end
end


def set_md5(client)
  t = "SELECT * FROM teachers_dayane"
  teachers = client.query(t).to_a

  teachers.each do |teacher|
    hash_t = Digest::MD5.hexdigest "#{teacher[:first_name]}#{teacher[:middle_name]}#{teacher[:last_name]}#{teacher[:birth_date]}#{teacher[:subject_id]}#{teacher[:current_age]}"
    update_qry = "UPDATE teachers_dayane SET md5 = \"#{hash_t}\" WHERE id = #{teacher['id']};"
    client.query(update_qry)
  end
end


=begin def get_class_info(id, client)
  c = "SELECT t.first_name, t.middle_name, t.last_name, c.name FROM teachers_dayane t
      JOIN teachers_classes_dayane tc ON t.subject_id = tc.teacher_id
      JOIN classes_dayane c ON tc.class_id = c.id WHERE tc.class_id = \"#{id}\";"
  results = client.query(c).to_a

  if results.empty?
    p "Class with #{id} was not found."
  else
    string = "Class name: #{results[0]['name']}\nResponsible Teacher:"
    results.each do |row|
      string += "#{row['first_name']} #{row['middle_name']} #{row['last_name']}\n"
    end
    puts string

  end
end
=end
def get_class_info(class_id, client)
  involved_teachers = "SELECT c.name, t.first_name, t.last_name
   FROM teachers_classes_dayane AS tc
     JOIN classes_dayane AS c
     ON tc.class_id = c.id
     JOIN teachers_dayane AS t
     ON tc.teacher_id = t.id
     WHERE c.id = #{class_id};"

  responsible_teacher = "SELECT c.name, t.first_name, t.last_name
   FROM classes_dayane AS c
     JOIN teachers_dayane AS t
       ON c.responsible_teacher_id = t.id
   WHERE c.id = #{class_id};"

  results_involved = client.query(involved_teachers).to_a
  results_responsible = client.query(responsible_teacher).to_a

  if results_involved.empty? || results_responsible.empty?
    puts "There are no involved or responsible teachers in class with id #{class_id}"
  else
    string = "Class name: #{results_responsible[0]['name']}\nResponsible teacher: #{results_responsible[0]['first_name']} #{results_responsible[0]['last_name']}\nInvolved teachers:\n"

    results_involved.each do |row|
      string += "#{row['first_name']} #{row['last_name']}\n"
    end

    puts string.strip
  end
end

def get_teachers_by_year(year, client)
  year_t = "SELECT t.first_name, t.last_name FROM teachers_dayane t WHERE YEAR(birth_date) = \"#{year}\";"
  results = client.query(year_t).to_a

  if results.empty?
    p "There are no teachers born in #{year}"
  else
    string = ""

    results.each do |row|
      string += "Teachers born in #{year}: #{row['first_name']} #{row['last_name']}"

    end
    p string
  end
end



