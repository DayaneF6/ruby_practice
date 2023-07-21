require 'mysql2'
require 'dotenv/load'
require_relative 'methods.rb'

client = Mysql2::Client.new(host: "db09.blockshopper.com", username: ENV['DB09_LGN'], password: ENV['DB09_PWD'], database: "applicant_tests")
=begin
get_teacher(3, client)
get_subject_teachers(1, client)
get_class_subjects('Math', client)
get_teachers_list_by_letter('Joao', 'Barbosa', client)
set_md5(client)
=end
get_class_info(3, client)

client.close
