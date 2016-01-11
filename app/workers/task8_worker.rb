require 'net/http'
class Task8Worker
  # include Sidekiq::Worker
  # sidekiq_options :retry => false

  def perform(question, token, task_id)
    letters = question.delete(' ')
    return if question.empty?
    letters_hash = 0
    letters.each_byte { |byte| letters_hash = letters_hash + byte }

    LineHash.where(letters_hash: [(letters_hash - 100)..(letters_hash + 100)], length: letters.length).each do |line_hash|
      if compare_lines(line_hash.letters, letters) then
        line = line_hash.line
        line = line[0...-2] if line.end_with?(' —')
        Thread.new { async_post line, token, task_id, question }
      end
    end
    nil
  end

  def compare_lines(line, letters)
    line_array = line.chars
    letters.chars.each do |char|
      delete_index = line_array.find_index(char)
      line_array.delete_at(delete_index) if delete_index
    end
    (line_array.count < 2)? true : false
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
