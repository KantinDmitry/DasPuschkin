require 'net/http'
class QuizController < ApplicationController
  protect_from_forgery with: :null_session

  def post
    token = '4e2b7974ca25f48a8ae26ca89b8f27ae'

    task_id = params[:id]
    task_level = params[:level]
    task_question = params[:question].delete(' ').strip
    task_level = task_level.to_i if task_level.class === 'String'

    case task_level
    when 1
      Task1Worker.new.perform(task_question, token, task_id)
    when 2
      Task2Worker.new.perform(task_question, token, task_id)
    when 3
      Task3Worker.new.perform(task_question, token, task_id)
    when 4
      Task3Worker.new.perform(task_question, token, task_id)
    when 5
      Task5Worker.new.perform(task_question, token, task_id)
    when 6
      Task6Worker.new.perform(task_question, token, task_id)
    when 7
      Task7Worker.new.perform(task_question, token, task_id)
    when 8
      Task8Worker.new.perform(task_question, token, task_id)
    else
      puts "Task lvl #{task_level} not supported. Question: #{task_question}"
    end
    render nothing: true
  end
end
