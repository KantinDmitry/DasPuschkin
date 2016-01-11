require 'net/http'
class Task5Worker
  # include Sidekiq::Worker
  # sidekiq_options :retry => false

  def perform(question, token, task_id)
    @token = token
    @task_id = task_id
    replasements = replace_each_word Regexp.escape(question)
    replasements.map! { |str| "(#{str})"}
    regexp = "(#{replasements.join('|')}){1}"
    result = Verse.where("text ~ ?", regexp).limit(1)[0]

    if result then
      result = result.text.match(regexp.gsub('\w', '\S')).to_s
      different_words = find_difference question, result
      @answer =  different_words.join ','
    else
      @answer = 'not found'
    end
    server_answer = send_answer
    puts "QUIZ lvl 5. Question: #{question.inspect};\tanswer: #{@answer};\tLine: #{result};  #{server_answer.class} - #{server_answer.body}"
  end

  def replace_each_word string
    replasements = []
    string.split.count.times do |i|
      words_array = string.split
      words_array[i].sub!(/^[А-Яа-яA-Za-z\-«»]+/, '[\w\-\?\.,«»]+')
      replasements.push words_array.join(' ')
    end
    replasements
  end

  def find_difference question, line
    @start_index = 0
    line.length.times do |i|
      if question[i] != line[i] then
        @start_index = i
        break
      end
    end
    correct_word = line[@start_index..-1].split[0].gsub(/[,\.!\?]/, '')
    incorrect_word = question[@start_index..-1].split[0].gsub(/[,\.!\?]/, '')
    [correct_word,incorrect_word]
  end

  def send_answer
    uri = URI("http://pushkin.rubyroid.by/quiz")
    answer_params = {
      answer: @answer,
      token: @token,
      task_id: @task_id
    }
    server_answer = Net::HTTP.post_form(uri, answer_params)
  end
end
