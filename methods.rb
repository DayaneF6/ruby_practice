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
      string = "Subject: #{results[0]['name']}\nTeachers:\n"
      results.each do |row|
        string += "#{row['first_name']} #{row['middle_name']} #{row['last_name']}\n"
      end
      puts string
      #p "Subject #{results[0]['name']} - Teacher #{results[0]['first_name']} #{results[0]['middle_name']} #{results[0]['last_name']}"
  end
end

def get_class_subjects(name, client)
  c = "SELECT s.name subject, c.name class, td.first_name, td.middle_name, td.last_name
    FROM classes_dayane c
    JOIN teachers_classes_dayane tc
      ON tc.class_id = c.id
    JOIN teachers_dayane td
      ON tc.teacher_id = td.id
    JOIN subjects_dayane s
      ON s.id = td.subject_id
    WHERE c.name = \"#{name}\"";
    # c = "SELECT c.name, td.first_name, td.middle_name, td.last_name FROM classes_dayane c
    #      JOIN teachers_dayane td ON td.id = c.responsible_teacher_id WHERE name = \"#{name}\""
    results = client.query(c).to_a

    if results.empty?
        p "Class with name #{name} was not found."
      else
        string = "Class: #{results[0]['class']}\nSubject: #{results[0]['subject']}\nTeachers:\n"
        results.each do |row|
          string += "#{row['first_name']} #{row['middle_name']} #{row['last_name']}\n"
        end
        puts string
        #p "Class #{results[0]['name']} - Teacher #{results[0]['first_name']} #{results[0]['middle_name']} #{results[0]['last_name']}"
    end
end

def get_teachers_list_by_letter(letter, client)
  tl = "SELECT s.name, t.first_name, t.middle_name, t.last_name FROM teachers_dayane t
        JOIN subjects_dayane s ON t.subject_id = s.id WHERE t.first_name
        LIKE '%#{letter}%' OR t.last_name LIKE '%#{letter}%'"

    results = client.query(tl).to_a

    if results.empty?
        p "Teacher with name #{letter} was not found."
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

#--------------------------------------------------------------------------------------------------------------------------------------
#exercicio para gerar registros na tabela

def random_date(st_date, end_date)
  st_date = Date.parse('1923-01-01')
  end_date = Date.parse('2023-08-01')
  random_date = rand(st_date..end_date)
  random_date.strftime('%Y-%m-%d')
end

def random_last_names(n, client)
  query = <<~SQL
      SELECT * FROM last_names
  SQL
  results = client.query(query).to_a.map{ |el| el['last_name'] } # turn it into an array of names
  random_names = []
  n.times do
    random_names << results.sample
  end
  random_names
end

def random_first_names(n, client)
  q = <<~SQL
    SELECT names FROM female_names
    UNION
    SELECT FirstName FROM male_names
    ORDER BY RAND()
    LIMIT #{n}
  SQL

  results = client.query(q).to_a

  results.map { |row| row['names'] }
end

def generate_random_people(client, n)
  create_table = <<~SQL
    CREATE TABLE IF NOT EXISTS random_people_dayane (
    id bigint(20) AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(70),
    birth_date DATE
    );
  SQL

  client.query(create_table)

  first_names = random_first_names(n, client)
  last_names = random_last_names(n, client)
  birth_dates = []

  n.times do
    birth_dates << random_date("1923-01-01","2023-01-01")
  end

  # data is an array of arrays with first_name, last_name and birth_date keys
  data = first_names.zip(last_names).zip(birth_dates).map(&:flatten)

  data.each_slice(10000) do |group|
    insert = "INSERT INTO random_people_dayane (first_name, last_name, birth_date) VALUES "

    # row is ["Name1", "Lastname", "2001-06-01"]
    group.each do |row|
      insert += "(\"#{row[0]}\", \"#{row[1]}\", \"#{row[2]}\"),"

    end
    client.query(insert.chop!)
  end
end

# def random_people(client, n)
#   if n <= 20000
#     generate_random_people(client, n)
#     else
#       random_people(20000, client)
#       random_people(n - 20000, client)
#   end
# end
#-----------------------------------------------------------------------------------------------------------------------------------
#exercicio montana

def create_montana_table (client)
  create_table = <<~SQL
    CREATE TABLE IF NOT EXISTS montana_public_district_report_card__uniq_dist_dayane (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(255),
      clean_name VARCHAR(255),
      address VARCHAR(255),
      city VARCHAR(255),
      state VARCHAR(10),
      zip INT,
      UNIQUE KEY unique_district (name, address, city, state, zip)
    );
  SQL

  client.query(create_table)
end

#primeira tentativa
# def unique_tables(client)
#     table = <<~SQL
#       SELECT school_name, address, city, state, zip FROM montana_public_district_report_card;
#     SQL
#     result = client.query(table)
#
#     #inserir na tabela
#     result.each do |row|
#       insert_table = <<~SQL
#         (
#         INSERT INTO montana_public_district_report_card__uniq_dist_dayane (name, address, city, state, zip)
#         VALUES ( '#{row['school_name']}', '#{row['address']}', '#{row['city']}', '#{row['state']}', '#{row['zip']}' )
#         );
#       SQL
#       client.query(insert_table)
#     end
# end

def clean_school_districts(client)

  create_montana_table (client)

    insert_data = <<~SQL
      INSERT IGNORE INTO montana_public_district_report_card__uniq_dist_dayane (name, address, city, state, zip)
        SELECT DISTINCT school_name, address, city, state, zip
        FROM montana_public_district_report_card;
    SQL

  client.query(insert_data)

    query = <<~SQl
      SELECT name FROM montana_public_district_report_card__uniq_dist_dayane WHERE clean_name IS NULL;
    SQl

  results = client.query(query)

  results.map do |row|
    name = row['name']
    clean = name.gsub(/\bElem\b|\bEl\b/, "Elementary School").gsub(/H S|\bHS\b/, "High School")
                     .gsub(/K-12|K-12 Schools/, "Public School").gsub(/\b(\w+)(\s(\1\b))+/, '\1')
                     .gsub(/School (\w+) (School)/, '\1 \2') + ' District'

    update_q = <<~SQL
        UPDATE montana_public_district_report_card__uniq_dist_dayane
        SET clean_name = '#{clean}'
        WHERE name = '#{name}'
    SQL

    client.query(update_q)
    end
  end

  # select_q = <<~SQL
  #   SELECT name FROM montana_public_district_report_card__uniq_dist_dayane;
  # SQL
  #
  # result = client.query(select_q)
  #
  # #limpar 'schools' repetidos
  # result.each do |row|
  #   name = row['name']
  #   clean = name.gsub(/\b(\w+)(\s(\1\b))+/, '\1').gsub(/School (\w+) (School)/, '\1 \2')
  #
  #   update_q = <<~SQL
  #   UPDATE montana_public_district_report_card__uniq_dist_dayane
  #   SET clean_name = '#{clean}'
  #   WHERE name = '#{name}'
  #  SQL
  #   client.query(update_q)
  # end


#------------------------------------------------------------------------------------------------------------------------------
# test:
# completed

def create_table(client)
  begin
    # criar a tabela
    create_table = <<~SQL
      CREATE TABLE IF NOT EXISTS hle_dev_test_dayane_santos AS
      SELECT * FROM hle_dev_test_candidates
    SQL

    client.query(create_table)

    # Se a criação da tabela for bem, adiciona as colunas
    alter_table = <<~SQL
      ALTER TABLE hle_dev_test_dayane_santos ADD COLUMN (clean_name VARCHAR(255), sentence VARCHAR(255));
    SQL

    client.query(alter_table)

  rescue Mysql2::Error => e
    #mostra uma mensagem de erro caso necessário
    p "Erro: #{e.message}"
  end
end

def escape(str)
  str = str.to_s
  return str if str == ''
  return if str == ''
  str.gsub(/\\/, '\&\&').gsub(/'/, "''")
end

def update_select_names(client)

  create_table(client)

  # a) get the candidate office names
  select_name = <<~SQL
    SELECT candidate_office_name FROM hle_dev_test_dayane_santos WHERE clean_name IS NULL;
  SQL

  result = client.query( select_name ).to_a

  # b)
  result.each do | row |
    name = row['candidate_office_name']
    up_candidate = name.downcase #ii
                       .gsub(/\bCounty Clerk\/Recorder\/DeKalb County\b/i, "DeKalb County clerk and recorder") #i
                       .gsub(/\bTwp\b/i, "Township") #v
                       .gsub(/\bHwy\b|\bhighway\b/i, "Highway") #vi vii
                       # .gsub(/\b(\w+),\s*(\w+)\b/) { |match| "(#{match[0]} #{match[1]})" }
                       .gsub(/\b(\w+),\s*(\w+)\b/) do |match| #iv
                          word1 = $1.capitalize
                          word2 = $2.capitalize
                          "(#{word1} #{word2})"
                       end
                       .gsub(/\.$/, '') # viii
                       .gsub(/(.+)\/(.+)/) { |match| "#{$2.capitalize} #{$1.downcase}" } # iii
                       .gsub(/\//) { |match| '' }

    # c)
    update_query = <<~SQL
      UPDATE hle_dev_test_dayane_santos
      SET clean_name = '#{escape(up_candidate)}'
      WHERE candidate_office_name = '#{escape(name)}'
    SQL

    client.query(update_query)
  end

  # d)
  sentence_query = <<~SQL
      SELECT sentence FROM hle_dev_test_dayane_santos;
    SQL

    client.query(sentence_query)

    #concatenação
    update_sentence = <<~SQL
      UPDATE hle_dev_test_dayane_santos
      SET sentence = CONCAT("The candidate is running for the ", clean_name, " office.")
    SQL

  client.query(update_sentence)

end
