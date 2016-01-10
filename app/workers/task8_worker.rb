require 'net/http'
class Task8Worker
  # include Sidekiq::Worker
  # sidekiq_options :retry => false

  def perform(question, token, task_id)
    letters = question.delete(' ')
    return if question.empty?

    Verse.all.each do |verse|
      verse.text.split("\n").each do |line|
        if compare_lines line, letters then
          line = line[0...-2] if line.end_with?(' —')
          Thread.new { async_post line, token, task_id, question }
        end
      end
    end
    puts "QUIZ lvl 8; question: #{question}"
  end

  def compare_lines(line, letters)
    return false if letters.length > line.length
    line_array = line.chars - ['.', ',', ':', ';', ':', '«', '»', '–', '—', '!', '?', '-', '"', ' ', '(', ')']
    if line_array.count == letters.length then
      letters.chars.each do |char|
        delete_index = line_array.find_index(char)
        line_array.delete_at(delete_index) if delete_index
      end
      return true if line_array.count < 3
    end
    false
  end

  def async_post(answer, token, task_id, question)
    uri = URI("http://pushkin.rubyroid.by/quiz")
    answer_params = {
      answer: answer,
      token: token,
      task_id: task_id
    }
    server_answer = Net::HTTP.post_form(uri, answer_params)
    puts "question: #{question}, answer: #{answer};  #{server_answer.class} - #{server_answer.body}"
  end
end
