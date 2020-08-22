puts "EventManager Initialized!"
require "csv"
require 'google/apis/civicinfo_v2'
require 'erb'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

def clean_zipcode(zipcode) 
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
                                  address: zip,
                                  levels: 'country',
                                  roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials 
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

=begin

def save_thank_you_letter id,form_letter
  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks_#{id}.html"
  File.open(filename,'w') do |file|
    file.puts form_letter
  end
  
end
=end

def clean_phone_numbers number
  number.gsub!(/[\D]/,'')
  if (number.length < 10 || (number.length == 11 && number[0] != 1) || number.length > 11) 
    #puts "Bad Number"
  elsif number.length == 10 
    number
  elsif number.length == 11 && number[0] == 1
    number = number[1..-1]
  end 
end





contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

times = {}
days = {}

def times_square trep,key 
  if trep[key]
    trep[key] += 1
  else 
    trep[key] = 1
  end
end

def days_fare container,element 
  if container[element].nil?
    container[element] = 1
  else 
    container[element] += 1
  end
end


contents.each do |row|
  id = row[0]
  days = {}
  name = row[:first_name]
  number = clean_phone_numbers(row[:homephone])
  
  
  time = DateTime.strptime(row[:regdate],'%m/%d/%Y %H:%M')
  hour_ = time.strftime("%H")
  dayat = time.wday
  
  
  times_square(times,hour_) 
  days_fare(days,dayat)
  
  zipcode = clean_zipcode(row[:zipcode])
  
  legislators = legislators_by_zipcode(zipcode)
  
  form_letter = erb_template.result(binding)
  
  #save_thank_you_letter(id,form_letter)

end


puts days
