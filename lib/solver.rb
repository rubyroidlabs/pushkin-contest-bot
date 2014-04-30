require 'pry'
require 'json'
require 'rest_client'

class Solver

  TOKEN='123'
  WORD=/А-Яа-яЁё0-9/

  def initialize
    @poems = JSON.parse(File.read(File.expand_path('../../db/poems.json', __FILE__)))
    @poem_lines = @poems.values.flatten.map{|line| strip_punctuation(line) }
    @poem_names = Hash[@poems.flat_map {|name, lines| lines.map {|line| [strip_punctuation(line), name]  }}]
  end

  def call(env)
    params = JSON.parse(env["rack.input"].read)
    answer = self.send("level_#{params["level"]}", params["question"])
    send_answer(answer, params)
    [200, {'Content-Type' => 'application/json'}, StringIO.new("Hello World!\n")]
  end

  def level_1(question)
    @poem_names[strip_punctuation(question)] || ""
  end

  def strip_punctuation(string)
    string.strip.gsub(/[[:punct:]]\z/, '')
  end

  def send_answer(answer, task_id)
    uri = URI("http://pushkin-contest.ror.by/quiz")

    data = { answer: answer, token: TOKEN, task_id: task_id }
    options = {content_type: :json, accept: :json}

    RestClient.post uri.to_s, data.to_json, options
  end

end
