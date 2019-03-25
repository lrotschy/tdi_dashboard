require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
require "tilt/erubis"
require "yaml"
require "bcrypt"
require "rinruby"
# require "descriptive-statistics"
# include Enumerable
# module Enumerable

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, escape_html: true
end

before do
  @data = YAML.load(File.read("data.yaml"))
  @visualizations = ["histogram", "boxplot", "stemplot", "etc."]
end

get "/" do
  redirect "/home"
end

get "/home" do
  @workshop_list = @data.keys
  erb :home, layout: :layout
end

get "/workshops" do
  @workshop = params[:workshop]
  @modules = @data[@workshop]
  erb :workshop, layout: :layout
  #generate diagram of modules and questions with heat applied to questions
end

def barplot(questions, stdevs, file_path)
  R.assign "questions", questions
  R.assign "stdevs", stdevs
  R.assign "file_path", file_path
  R.eval "jpeg(filename=file_path)"
  R.eval "par(mar=c(15,4,4,7))"
  R.eval "par(las=2)"
  R.eval "barplot(stdevs,names.arg=questions,ylab='Standard Deviation',main='Standard Deviations of Responses')"
  R.eval "dev.off()"
end

def stdevs_all_questions(questions, pre_post)
  stdevs = []
  questions.each do |question, responses|
    stdevs << standard_deviation(questions[question][pre_post].values)
  end
  stdevs
end

def post_data?(mod)
  mod.values.any? { |hash| hash.keys.include?("post")}
end

def pre_data?(mod)
  mod.values.any? { |hash| hash.keys.include?("pre")}
end

get "/workshops/:workshop" do
  @workshop = params[:workshop]
  @module = params[:module]
  @questions = @data[@workshop][@module].keys

  if pre_data?(@data[@workshop][@module])
    @stdevs_pre = stdevs_all_questions(@data[@workshop][@module], "pre")
    barplot(@questions, @stdevs_pre, 'public/visuals/pre_dialogue_barplot.jpg')
  end

  if post_data?(@data[@workshop][@module])
    @stdevs_post = stdevs_all_questions(@data[@workshop][@module], "post")
    barplot(@questions, @stdevs_post, 'public/visuals/post_dialogue_barplot.jpg')
  end

  erb :module, layout: :main_page_layout
end

get "/workshops/:workshop/:module/visuals" do
  @workshop = params[:workshop]
  @module = params[:module]
  @visualization = params[:visualization]
  @questions = @data[@workshop][@module].keys

  if pre_data?(@data[@workshop][@module])
    @stdevs_pre = stdevs_all_questions(@data[@workshop][@module], "pre")
    barplot(@questions, @stdevs_pre, 'public/visuals/pre_dialogue_barplot.jpg')
  end

  if post_data?(@data[@workshop][@module])
    @stdevs_post = stdevs_all_questions(@data[@workshop][@module], "post")
    barplot(@questions, @stdevs_post, 'public/visuals/post_dialogue_barplot.jpg')
  end

  erb :module, layout: :main_page_layout
end

def standard_deviation(array)
  R.assign "numbers", array
  x = R.pull "sd(numbers)"
end

def mean(array)
  sum = 0
  array.each do |x|
    sum = sum + x.to_f
  end
  sum/array.length
end

def box_plot(scores, file_path)
  R.assign "scores", scores
  R.assign "file_path", file_path
  R.eval "jpeg(filename=file_path)"
  R.eval "boxplot(scores, ylab='Likert Scores')"
  R.eval "dev.off()"
end

def histogram(scores, file_path)
  R.assign "scores", scores
  R.assign "file_path", file_path
  R.eval "jpeg(filename=file_path)"
  R.eval "hist(scores, xlab='Likert Scores')"
  R.eval "dev.off()"
end

def stemplot(scores)

end

get "/workshops/:workshop/:module" do
  @workshop = params[:workshop]
  @module = params[:module]
  @question = params[:question]
  erb :question, layout: :main_page_layout
end

def file_path(pre_post)
  pre_post == "pre" ? "/visuals/pre_dialogue" : "/visuals/post_dialogue"
end

def select_vis(visualization)
  case visualization
  when "histogram"
    "_histogram.jpg"
  when "boxplot"
    "_boxplot.jpg"
  when "stemplot"
    "_stemplot.jpg"
  when "barplot"
    "_barplot.jpg"
  end
end

def get_file_path(pre_post, visualization)
  file_path(pre_post) + select_vis(visualization)
end

get "/workshops/:workshop/:module/:question" do
  @workshop = params[:workshop]
  @module = params[:module]
  @question = params[:question]
  @visualization = params[:visualization]

  if pre_data?(@data[@workshop][@module])
    @pre_scores = @data[@workshop][@module][@question]["pre"].values.map(&:to_i)
    @stdev_pre = standard_deviation(@pre_scores)
    box_plot(@pre_scores, 'public/visuals/pre_dialogue_boxplot.jpg')
    histogram(@pre_scores, 'public/visuals/pre_dialogue_histogram.jpg')
  end

  if post_data?(@data[@workshop][@module])
    @post_scores = @data[@workshop][@module][@question]["post"].values.map(&:to_i)
    box_plot(@post_scores, 'public/visuals/post_dialogue_boxplot.jpg')
    histogram(@post_scores, 'public/visuals/post_dialogue_histogram.jpg')
    @stdev_post = standard_deviation(@post_scores)
  end

  erb :question, layout: :main_page_layout
end

get "/practice_menu/:workshop" do
  @workshop = "Fake Workshop 1"

  erb :practice_menu, layout: :layout
end
