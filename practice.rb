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
  end
  
  get_data_from_table(client)

client.close