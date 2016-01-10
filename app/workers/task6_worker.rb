require 'net/http'
class Task6Worker
  # include Sidekiq::Worker
  # sidekiq_options :retry => false

  def perform(question, token, task_id)
    words_array = question.split
    words_array.map! do |word|
      length = word.length
      word = "[#{word}]{#{length}}".insert(-1, '[ .,–—!\?;:«»\(\)]*')
    end
    pattern = words_array.join

    request_result = Verse.where("text ~ ?", pattern).limit(1)[0]

    if request_result then
      answer = request_result.text.match(pattern).to_s
    else
      answer = 'not found'
    end

    uri = URI("http://pushkin.rubyroid.by/quiz")
    answer_params = {
      answer: answer,
      token: token,
      task_id: task_id
    }
    server_answer = Net::HTTP.post_form(uri, answer_params)
    puts "QUIZ lvl 6. Question: {#{question}};\tanswer: {#{answer}};  #{server_answer.class} - #{server_answer.body}"
  end
end
