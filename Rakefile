puts "################################################\n"
puts "#####        Mystic Ticket System         ######\n"
puts "################################################\n"

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'


puts "\n\nPlease read INSTALL if you need help with anything!\n\n"

namespace :mystic do

 desc "Fill Mystic with sample data"
 task :fill_with_sample_data => :environment do
  # make users   
  @user_counter = 1000
  while @user_counter < 6000 #loop 1000 times 
    @user_query = "insert into users(id, first_name, last_name, email, type_id, password_hash, phone_number)  values( #{@user_counter}, 'John', 'Doe', 'user#{@user_counter}@test.com', 1, '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', '5551119100')"
    ActiveRecord::Base.connection.execute(@user_query)
    puts "inserted user: #{@user_counter}\n"
    @user_counter += 1
  end
     
  # make tickets
  @tick_counter = 1000
  while @tick_counter < 11000 #loop 
    @ticket_query = "INSERT INTO `tickets` VALUES(#{@tick_counter}, 'SampleTicket: #{@tick_counter}', 1, 1, 1, '2007-09-15 12:00:00', '2007-09-15 12:00:00');"
    ActiveRecord::Base.connection.execute(@ticket_query)
    puts "inserted ticket: #{@tick_counter}\n"
  
    # make tickettexts(aka posts)
    @post_counter = 0
    while @post_counter < 1 # make x posts for the ticket
      @tickettext_query = "INSERT INTO tickettexts(id, ticket_id, post_type, user_id, text_content, created_at)VALUES (#{@post_counter + @tick_counter}, #{@tick_counter}, 'user-post', 1, 'SAMPLE POST: #{@tick_counter} Number #{@post_counter}', '2007-09-15 12:00:00')"
      ActiveRecord::Base.connection.execute(@tickettext_query)
      @post_counter += 1
    end

    # make logs ( 1 per ticket ) 
     @ticketlog_query = "INSERT INTO ticketlogs(ticket_id, user_id, created_at, log_type, log) values(#{@tick_counter}, #{@tick_counter}, '2007-12-14 14:02:32', 'save_post', 'Added post(tech-reply)')"
     ActiveRecord::Base.connection.execute(@ticketlog_query)

     
    @tick_counter += 1
  end
 end

 desc "This will clean out all old log files, 1 months or older."
 task :clean_logs_1_month => :environment do  
  @logs = Ticketlog.find(:all, :conditions => ["created_at < ?", Time.now.months_ago(1) ] ) 
  puts "Deleting #{@logs.size} logs that are older than #{Time.now.months_ago(1)}\n"
  @logs.each do |log|
   puts "Deleting #{log.id} -- Type: #{log.log_type} -- Ticket: #{log.ticket_id}\n"
   log.destroy
  end 
 end 

 desc "This will clean out all old log files, 6 months or older."
 task :clean_logs => :environment do  
  @logs = Ticketlog.find(:all, :conditions => ["created_at < ?", Time.now.months_ago(6) ] ) 
  puts "Deleting #{@logs.size} logs that are older than #{Time.now.months_ago(6)}\n"
  @logs.each do |log|
   puts "Deleting #{log.id} -- Type: #{log.log_type} -- Ticket: #{log.ticket_id}\n"
   log.destroy
  end 
 end 

 
end

