require 'net/http'
class Task2Worker
  # include Sidekiq::Worker
  # sidekiq_options :retry => false

  def perform(question, token, task_id)
    reg_exp = Regexp.escape(question).sub('%WORD%', '[\w\-«\?,\.>]*')
    request_result = Verse.where("text ~ ?", reg_exp).limit(1)[0]

    if request_result then
      text = request_result.text.match(reg_exp.sub('\w', '\S')).to_s
      word_start_index = question.index '%WORD%'
      text_after_WORD = question[(word_start_index + 6)..-1]
      word_end_index = text.index text_after_WORD, word_start_index
      if text_after_WORD.empty? then
        answer = text[word_start_index..-1]
      else
        answer = text[word_start_index...word_end_index]
      end
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
    puts "QUIZ lvl 2. Question: #{question};\tanswer: #{answer}; #{server_answer.class} - #{server_answer.body}"
  end
end
