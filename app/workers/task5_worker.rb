require 'net/http'
class Task5Worker
  # include Sidekiq::Worker
  # sidekiq_options :retry => false

  def perform(question, token, task_id)
    # question = Regexp.escape question
    @token = token
    @task_id = task_id
    request_array = replace_each_word Regexp.escape(question)

    start = Time.now
    # Thread.abort_on_exception = true
    request_array.each do |request_pattern|
      thread_function request_pattern, question, start
      # Thread.new { thread_function request_pattern, question, start }
    end
    puts "QUIZ lvl 5. Q: #{question}"
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

  def thread_function request_pattern, question, start
    request_result = Verse.where("text ~ ?", request_pattern).limit(1)[0]

    if request_result
      puts "Time: #{(Time.now - start)*1000}"
      text = request_result.text.match(request_pattern.sub('\w', '\S')).to_s
      start_index = request_pattern.gsub("\\",'').index '[w'
      correct_word = text[start_index..-1].split[0].gsub(/[,\.]/,'')
      incorrect_word = question[start_index..-1].split[0].gsub(/[,\.]/,'')
      answer = "#{correct_word},#{incorrect_word}"
    end

    if answer
      uri = URI("http://pushkin.rubyroid.by/quiz")
      answer_params = {
        answer: answer,
        token: @token,
        task_id: @task_id
      }
      server_answer = Net::HTTP.post_form(uri, answer_params)
      puts "QUIZ lvl 5. Question: #{question.inspect};\tanswer: #{answer};\tLine: #{text};  #{server_answer.class} - #{server_answer.body}"
    end
  end
end
