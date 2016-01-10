require 'net/http'
class Task1Worker
  # include Sidekiq::Worker
  # sidekiq_options :retry => false

  def perform(question, token, task_id)
    request_result = Verse.where("text LIKE ?", "%#{question}%").limit(1)[0]
    answer = request_result.nil?? 'not found' : request_result.title

    uri = URI("http://pushkin.rubyroid.by/quiz")
    answer_params = {
      answer: answer,
      token: token,
      task_id: task_id
    }

    server_answer = Net::HTTP.post_form(uri, answer_params)

    puts "QUIZ lvl 1. Question: #{question};\tanswer: #{answer};  #{server_answer.class} - #{server_answer.body}"
  end
end
