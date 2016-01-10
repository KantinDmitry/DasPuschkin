class RegistrationController < ApplicationController
  # protect_from_forgery with: :null_session
  skip_before_filter  :verify_authenticity_token
  def index
    @verses = Verse.all
  end

  def post
    puts "Post registrations params: #{params}"
    # TODO do it with sidekiq... or not
    # token_file = File.open('app/token.txt', 'wt')
    # token_file.write params[:token]
    # token_file.close

    question = params[:question]
    reg_exp = question.sub('%WORD%', '\w+')
    request_result = Verse.where("text ~* ?", reg_exp)[0]
    if request_result then
      answer = request_result.text.match(reg_exp.sub('\w+', '\S+'))
      start_index = question.index '%WORD%'
      answer = answer.to_s[start_index..-1].split[0].match(/[^,.]+/).to_s
    else
      answer = 'not found'
    end

    render json: {answer: answer}
  end
end
