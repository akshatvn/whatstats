require 'csv'
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
  end

  def initialize_text_map
    @text_map = {}
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

  private

  def split_message_into_components msg
    data = msg.match(/^(\[)?(\d{1,2}\/\d{1,2}\/\d{1,2}),\s(\d{1,2}:\d{1,2}(:\d{1,2})?)\s(AM|PM)(\])?\s(-)?(\s)?(.*):\s(.*)/)
    return nil if !data || !data[10]
    return {
      date: data[2],
      time_12hr: data[3],
      am_pm: data[5],
      sender: data[9],
      text: data[10]
    }
  end



  

end
