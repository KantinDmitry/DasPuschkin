require 'net/http'
class Task7Worker
  # include Sidekiq::Worker
  # sidekiq_options :retry => false

  def perform(question, token, task_id)
    request_string = question.delete ' '
    request_string = request_string.split('').sort.join
    result = LineHash.where("letters LIKE ?", "%#{request_string}%").limit(1)[0]

    if result then
      answer = result.line
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
    puts "QUIZ lvl 7. Question: {#{question}};\tanswer: {#{answer}}; #{server_answer.class} - #{server_answer.body}"
  end
end
