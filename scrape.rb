require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'mysql2'
require 'dotenv/load'
require 'redis'

#conexao ao banco
client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")

# #selecao dos dados que queremos na pagina web
# doc = Nokogiri::HTML(URI.open('https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population'))
#
# #loop para ver os elementos
# doc.css('table.wikitable tr').each do |row|
#   cells = row.css('td, th').map(&:text).map(&:strip)
#   puts cells.join(' | ')
# end

# #conexão com o Redis
# redis = Redis.new

# def cache_handling (url, redis)
#   begin
#     #verifica se há um valor armazenado no cache do Redis para a chave url
#     cached_page = redis.get(url)
#
#     if cached_page
#       puts "Recuperando página em cache: #{url}"
#       return cached_page
#     else
#       puts "Fazendo solicitação para: #{url}"
#       page = open(url)
#
#       if page
#         redis.setex(url, 3600, page.to_s)  # Armazena a pagina em cache no Redis em cache por uma hora (3600 segundos)
#         return page
#       else
#         puts "Erro ao abrir a página: #{url}"
#       end
#     end
#   rescue Redis::ConnectionError => e
#     puts "Erro: #{e.message}"
#   end
# end

def create_table(client)
  begin
    # criar a tabela
    create_table = <<~SQL
      CREATE TABLE scrape_db09_dayane (
      Id INT AUTO_INCREMENT PRIMARY KEY,
      Country VARCHAR(255),
      Population VARCHAR(255),
      Percent VARCHAR(255),
      Dates VARCHAR(255),
      Source VARCHAR(255),
      UNIQUE KEY unique_country (Country)
    );
    SQL

    client.query(create_table)

  rescue Mysql2::Error => e
    #mostra uma mensagem de erro caso necessário
    p "Erro: #{e.message}"
  end
end

# armazena o cache em memória
$cache = {}

#tratamento de cache
def cache_handling(url)

  if $cache.key?(url)

    puts "Retrieving from cache: #{url}"

    return $cache[url]
  else

    puts "Fetching and caching: #{url}"
    response = URI.open(url).read
    $cache[url] = response

    return response
  end

end

def populating_table(client)
  create_table(client)

  url = 'https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population'
  html = cache_handling(url)

  doc = Nokogiri::HTML(html)
  cells = Array.new

  doc.css('table.wikitable tr').each do |row|
    names = row.css('td, th').map(&:text).map(&:strip)
    cells << names
  end

  cells[1..-1].each do |row|
    country = row[1].strip
    population = row[2]
    percent = row[3]
    dates = row[4]
    source = row[5].gsub(/\[\d+\]/, '')
    added_col = <<~SQL
    INSERT INTO scrape_db09_dayane (Country, Population, Percent, Dates, Source)
    VALUES ('#{country}', '#{population}', '#{percent}', '#{dates}', '#{source}')
    SQL

    client.query(added_col)
  end

end

populating_table(client)

