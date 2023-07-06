require 'mysql2'

client = Mysql2::Client.new(
  host: 'localhost',
  username: 'root',
  password: '',
  database: 'DBdayane_test'
)

query = "SELECT * FROM people_dayane"
results = client.query(query)    # Exibir os registros retornados

#mostrar os 10 primeiros registros na tabela
results.first(10).each do |row|
  p "ID: #{row['id']}"
  p "First Name: #{row['firstname']}"
  p "Last Name: #{row['lastname']}"
  p "Email: #{row['email']}"
  p "---------------------"
end

#contar a quantidade de 'doctor'
query = "SELECT COUNT(*) AS count FROM people_dayane WHERE profession = 'doctor'"
result = client.query(query).first
p "Count of people with profession 'doctor': #{result['count']}"

#substituicao de gmail para hotmail para profession ecologist
select_query = <<~SQL
    SELECT * FROM people_dayane ;
    SQL
update_query = <<~SQL
  UPDATE people_dayane  
  SET email2 = REPLACE(email2, '@gmail.com', '@hotmail.com')
  WHERE profession = 'Ecologist';
  SQL

client.query(update_query)

client.close

