require 'mysql2'
require 'dotenv/load'
require_relative 'methods.rb'
# require_relative 'add_data.rb'

client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")

=begin
get_teacher(3, client)
get_subject_teachers(1, client)
get_class_subjects('physics', client)
get_teachers_list_by_letter('Barbosa', client)
set_md5(client)
get_class_info(3, client)
get_teachers_by_year(1997, client)
=end

#generate_random_people(client, 10)
clean_school_districts(client)
# delete_duplicate(client)

client.close
