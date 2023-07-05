require 'mysql2'

client = Mysql2::Client.new(
  host: 'localhost',
  username: 'root',
  password: '',
  database: 'DBdayane_test'
)

def get_data_from_table(client)
    select_query = <<~SQL
      SELECT * FROM people_dayane ;
    SQL
    data_from_table = client.query(select_query).to_a # returns array of hashes - [{"id"=>1,"first_name"=>"Ted", ...}, {"id"=>2,"first_name"=>"Harry", ...}, ...]
    data_from_table.each do |row|
      update_query = <<~SQL
        UPDATE people_dayane 
        SET email = "#{row['firstname'].upcase}" -- edits column firstname by iterating through each row one at a time and running an update command with .downcase on each name 
        WHERE id = #{row['id']}; -- specifies that it is only updating the one row, not the whole table

      SQL
      client.query(update_query)
    end

    select_query = <<~SQL
      SELECT * FROM people_dayane ;
    SQL
    data_from_table = client.query(select_query).to_a 
    data_from_table.each do |row|
      update_query = <<~SQL
        UPDATE people_dayane 
        SET profession = "#{row['profession'].strip}" 
        WHERE id = #{row['id']}; 

      SQL
      client.query(update_query)
    end

  end

  def get_emails_lowercase(client)
    select_query = <<~SQL
      SELECT * FROM people_dayane ;
    SQL
    data_from_table = client.query(select_query).to_a 
    data_from_table.each do |row|
      update_query = <<~SQL
        UPDATE people_dayane 
        SET email2 = "#{row['email2'].downcase}" 
        WHERE id = #{row['id']}; 

      SQL
      client.query(update_query)
    end
  end

  def update_lastnames(client)
    select_query = <<~SQL
      SELECT * FROM people_dayane ;
    SQL
    data_from_table = client.query(select_query).to_a 
    data_from_table.each do |row|
    lastname = row['lastname']; # Armazena o nome atual numa variável
    unless row['lastname'].match?(/edited$/) # Se o nome atual não tem "edited"...
    updated_lastname = "#{lastname} edited" # Atualiza a variável lastname adicionando um "edited" no final e armazena esse resultado em outra variável chamada updated_lastname
    update_query = <<~SQL
      UPDATE people_dayane
      SET lastname = "#{updated_lastname}"
      WHERE id = #{row['id']};

    SQL
    client.query(update_query)
    end
  end
end

  #update_query = <<~SQL
  #UPDATE people_dayane
  #SET lastname = REPLACE(lastname, 'edited', '')  # Método que atualiza os sobrenomes removendo toda ocorrência de "edited" por uma string vazia
  #SQL
  #client.query(update_query)

  update_lastnames(client)
  get_emails_lowercase(client)
  get_data_from_table(client)

client.close