require 'net/http'
class Task7Worker
  # include Sidekiq::Worker
  # sidekiq_options :retry => false

  def perform(question, token, task_id)
    words_count = question.count(' ') + 1
    symbols = question.delete(' ').split('').uniq.sort.join

    find_line symbols, words_count
    find_line(symbols, words_count + 1) unless @line_is_matching
    find_line(symbols, words_count - 1) unless @line_is_matching

    if @line_is_matching then
      answer = @verse_line
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

  def find_line(symbols, words_count)
    return if words_count == 0
    pattern = "\n([#{symbols}]+[ \.,–—!\?;:«»]+){#{words_count-1}}" if words_count > 1
    pattern = "\n" unless words_count > 1
    pattern = "#{pattern}[#{symbols}]+[ \"\.,\-–—!\?;:«»]*\n"
    request_result = Verse.where("text ~ ?", pattern)

    request_result.each do |verse|
      @verse_line = verse.text.match(pattern).to_s.strip
      @line_is_matching = @verse_line.chars.uniq.sort.join.index symbols
      break if @line_is_matching
    end
  end
end
