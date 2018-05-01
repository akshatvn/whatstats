require 'csv'
require 'time'
class Analyser
  #  filename = "WhatsApp Chat with Jeeju ke saale.txt"
  def import filename
    filename_for_dirs = filename.gsub(/\s/,'-').gsub(/.txt$/,'')
    initialize_text_map
    messages = File.read(File.join(".","../conversations/#{filename}"))
    return if messages.size == 0
    messages = messages.split("\n")

    system "mkdir -p ./../reports/#{filename_for_dirs}/"
    CSV.open("./../reports/#{filename_for_dirs}/all_texts.csv", 'wb') do |csv|
      csv << ["Sender","Date","Time","AM/PM","Text"]
      messages.each do |message|
        if msg_data = split_message_into_components(message)
          csv << [
            msg_data[:sender],
            msg_data[:date],
            msg_data[:time_12hr],
            msg_data[:am_pm],
            msg_data[:text]          
          ]
          break_text_into_words(msg_data[:text])
          
        end
      end
    end

    CSV.open("./../reports/#{filename_for_dirs}/word_count.csv", 'wb') do |csv|
      csv << ["Word","Count"]
      @text_map.to_a.sort {|x,y| x[1] <=> y[1] }.each do |word, count|
        csv << [
          word, count
        ]
      end
    end

    CSV.open("./../reports/#{filename_for_dirs}/text_density.csv", 'wb') do |csv|
      csv << ["Date","Time","Count"]
      @date_time_counts.to_a.sort {|x,y| x[0] <=> y[0] }.each do |date, data|
        data.to_a.sort {|x,y| x[0] <=> y[0] }.each do |time,count|
          csv << [ date, time, count ]
        end
        
      end
    end

    CSV.open("./../reports/#{filename_for_dirs}/hourly_conc.csv", 'wb') do |csv|
      csv << ["Hour","Count"]
      @time_counts.to_a.sort {|x,y| time_map.index(x[0]) <=> time_map.index(y[0]) }.each do |time, count|
        csv << [ time, count ]
      end
    end

  end

  def initialize_text_map
    @date_time_counts ={}
    @text_map = {}
    @time_counts = {}
  end

  def break_text_into_words text
    text.split(/\W+/).each do |word|
      word = word.downcase
      if word.size > 0
        if @text_map[word]
          @text_map[word] += 1
        else
          @text_map[word] = 1
        end
      end
    end
  end

  def record_timestamp matchdata
    if matchdata[1] && matchdata[1] == '[' # ios format
      str_date = matchdata[2]
      date,month,year = str_date.split('/')
      year = '20' + year
      str_time = matchdata[3].match(/(\d{1,2}:\d{1,2})/)[1]
      hour = str_time.split(":")[0]
      am_pm = matchdata[5]
      msg_date = "#{year}-#{month}-#{date}"
      msg_time = "#{hour} #{am_pm}"
    else
      str_date = matchdata[2]
      month,date,year = str_date.split('/')
      year = '20' + year
      str_time = matchdata[3]
      hour = str_time.split(":")[0]
      am_pm = matchdata[5]
      msg_date = "#{year}-#{month}-#{date}"
      msg_time = "#{hour} #{am_pm}"
    end
    if !@time_counts[msg_time]
      @time_counts[msg_time] = 0
    end
    @time_counts[msg_time] += 1
    if !@date_time_counts[msg_date]
      @date_time_counts[msg_date] = {}
    end
    if !@date_time_counts[msg_date][msg_time]
      @date_time_counts[msg_date][msg_time] = 0
    end
    @date_time_counts[msg_date][msg_time] += 1
  end

  private

  def split_message_into_components msg
    data = msg.match(/^(\[)?(\d{1,2}\/\d{1,2}\/\d{1,2}),\s(\d{1,2}:\d{1,2}(:\d{1,2})?)\s(AM|PM)(\])?\s(-)?(\s)?(.*):\s(.*)/)
    return nil if !data || !data[10]
    record_timestamp(data)
    return {
      date: data[2],
      time_12hr: data[3],
      am_pm: data[5],
      sender: data[9],
      text: data[10]
    }
  end

  def time_map
    @time_map ||= [
      "12 AM",
      "1 AM",
      "2 AM",
      "3 AM",
      "4 AM",
      "5 AM",
      "6 AM",
      "7 AM",
      "8 AM",
      "9 AM",
      "10 AM",
      "11 AM",
      "12 PM",
      "1 PM",
      "2 PM",
      "3 PM",
      "4 PM",
      "5 PM",
      "6 PM",
      "7 PM",
      "8 PM",
      "9 PM",
      "10 PM",
      "11 PM"
    ]
  end



  

end
