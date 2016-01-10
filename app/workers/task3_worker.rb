require 'net/http'
class Task3Worker
  # include Sidekiq::Worker
  # sidekiq_options :retry => false

  def perform(question, token, task_id)
    reg_exp = Regexp.escape(question).gsub('%WORD%', '[\w\-«\?,\.>]+')
    request_result = Verse.where("text ~ ?", reg_exp).limit(1)[0]

    if request_result
      text = request_result.text.match(reg_exp.gsub('\w', '\S')).to_s
      answer = find_words question, text
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
    puts "QUIZ lvl 2-4. Question: #{question.inspect};\tanswer: #{answer};  #{server_answer.class} - #{server_answer.body}"
  end

  def find_words question, text
    answer = []
    text_strings = text.split("\n")
    question_strings = question.split("\n")

    text_strings.count.times do |i|
      word_start_index = question_strings[i].index '%WORD%'
      text_after_WORD = question_strings[i][(word_start_index + 6)..-1]
      word_end_index = text_strings[i].index text_after_WORD, word_start_index + 1
      if text_after_WORD.empty?
        answer.push text_strings[i].split.last
        next
      end
      answer.push text_strings[i][word_start_index...word_end_index]
    end
    answer.join ','
  end
end
