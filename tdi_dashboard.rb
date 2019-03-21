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
  @visualizations = ["histogram", "boxplot", "etc."]
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
  R.eval "png(filename=filepath)"
  R eval "barplot(stdevs,names.arg=questions)"
  R.eval "dev.off()"
end

# def stdevs_all_questions(questions, pre_post)
#   stdevs = []
#   questions.each do |question, __|
#     stdevs << standard_deviation(question[pre_post].values)
#   end
#   stdevs
# end


get "/workshops/:workshop" do
  @workshop = params[:workshop]
  @module = params[:module]
  @questions = @data[@workshop][@module]
  # @stdevs_pre = stdevs_all_questions(@module, "pre")
  # @stdevs_post = stdevs_all_questions(@module, "post")
  # barplot(@questions, stdevs_pre, 'public/barplot_pre.png')
  # barplot(@questions, stdevs_post, 'public/barplot_post.png')

  #
  # @pre_scores = @data[@workshop][@module][@question]["pre"].values.map(&:to_i)
  # @stdev_pre = standard_deviation(@pre_scores)
  # box_plot_pre(@pre_scores)
  #
  #generate boxplots for each question and display with heat on labels?

  erb :module, layout: :layout
end

def standard_deviation(array)
  sum = 0
  array.each do |x|
    sum = sum + x.to_f
  end
  mean = sum/array.length

  deviations = []
  array.each do |x|
    deviations.push((mean - x)*(mean - x))
  end

  sum_of_deviations = 0
  deviations.each do |x|
    sum_of_deviations += x
  end

  Math.sqrt((sum_of_deviations)/(array.length-1))
end

def mean(array)
  sum = 0
  array.each do |x|
    sum = sum + x.to_f
  end
  sum/array.length
end



# def box_plot_pre(scores)
#   R.assign "scores", scores
#
#   R.eval "jpeg(filename='public/pre_score_boxplot.jpg')"
#   R.eval "boxplot(scores)"
#   R.eval "dev.off()"
# end
#
# def box_plot_post(scores)
#   R.assign "scores", scores
#
#   R.eval "jpeg(filename='public/post_score_boxplot.jpg')"
#   R.eval "boxplot(scores)"
#   R.eval "dev.off()"
# end
#
# def box_plot(scores)
#   R.assign "scores", scores
#
#   R.eval "jpeg(filename='public/score_boxplot.jpg')"
#   R.eval "boxplot(scores)"
#   R.eval "dev.off()"
# end
def box_plot(scores, file_path)
  R.assign "scores", scores
  # R.eval file_path <- file_path
  R.assign "file_path", file_path
  R.eval "jpeg(filename=file_path)"
  R.eval "boxplot(scores)"
  R.eval "dev.off()"
end

def histogram(scores, file_path)
  R.assign "scores", scores
  # R.eval file_path <- file_path
  R.assign "file_path", file_path
  R.eval "jpeg(filename=file_path)"
  R.eval "hist(scores)"
  R.eval "dev.off()"
end


#   > M <- c("Reality if overrated", "Science is fake")
# > png(filename="/Users/lielarotschy/Desktop/bargraph_stdev.png")
# > H <- c(2.9, 1.0)
# > barplot(H,names.arg=M,xlab="Question",ylab="StDev",main="Questions by StDev")
# > dev.off

get "/workshops/:workshop/:module" do
  @workshop = params[:workshop]
  @module = params[:module]
  @question = params[:question]

  @pre_scores = @data[@workshop][@module][@question]["pre"].values.map(&:to_i)
  @stdev_pre = standard_deviation(@pre_scores)
  # box_plot_pre(@pre_scores)
  box_plot(@pre_scores, 'public/pre_score_boxplot.jpg')
  histogram(@pre_scores, 'public/pre_score_histogram.jpg')

  @post_scores = @data[@workshop][@module][@question]["post"].values.map(&:to_i)
  # box_plot_post(@post_scores)
  box_plot(@post_scores, 'public/post_score_boxplot.jpg')
  histogram(@post_scores, 'public/post_score_histogram.jpg')

  @stdev_post = standard_deviation(@post_scores)

  erb :question, layout: :layout
end
