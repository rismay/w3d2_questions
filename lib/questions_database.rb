require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super("questions.db")
    self.results_as_hash = true
    self.type_translation = true
  end

end

class User
  attr_accessor :id, :fname, :lname

  def self.find_by_id( user_id )
    user_data = QuestionsDatabase.instance.get_first_row(<<-SQL, :user_id => user_id)
    SELECT
    *
    FROM
    users
    WHERE
    id = :user_id
    SQL

    User.new(user_data)
  end

  def self.find_by_name( fname, lname )
    user_data = QuestionsDatabase.instance.get_first_row(<<-SQL, :fname => fname, :lname => lname)
    SELECT
    *
    FROM
    users
    WHERE
    fname = :fname, lname = :lname
    SQL

    User.new(user_data)
  end

  # get all questions belonging to User
  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    reply_data = QuestionsDatabase.instance.execute(<<-SQL, :own_id => self.id)
    SELECT
    *
    FROM
    replies
    WHERE
    id = :own_id
    SQL

    reply_data.map { |reply| Reply.new(reply) }
  end

  def initialize( options = {} )
    @id, @fname, @lname = options.values_at(:id, :fname, :lname)
  end

end


class Question
  attr_accessor :title, :body, :author_id, :author, :replies

  def self.find_by_id( q_id )
    question_data = QuestionsDatabase.instance.get_first_row(<<-SQL, :q_id => q_id)
    SELECT
    *
    FROM
    questions
    WHERE
    :q_id = id
    SQL

    Question.new(question_data)
  end

  def self.find_by_author_id( auth_id )
    author_data = QuestionsDatabase.instance.execute(<<-SQL :auth_id => auth_id)
    SELECT
      *
    FROM
      questions
    WHERE
      author_id = :auth_id
    SQL

    author_data.map { |question| Question.new(question) }
  end

  def author
    @author ||= User.find_by_id(self.author_id)
  end

  def replies
    Reply.find_by_question_id(self.id)
  end

  def initialize( options = {} )
    @id, @title, @body, @author_id = options.values_at(:id, :title, :body, :author_id)
  end

end

class QuestionFollower
  attr_accessor :question_id, :user_id

  def self.find_by_id( qf_id )
    follower_data = QuestionsDatabase.instance.get_first_row(<<-SQL, :qf_id => qf_id)
    SELECT
    user_id
    FROM
    question_followers
    WHERE
    :qf_id = id
    SQL

    QuestionFollower.new(follower_data)
  end

  def initialize( options = {} )
    @id, @question_id, @user_id = options.values_at(:id, :question_id, :user_id)
  end

end


class Reply

  attr_accessor :id, :question_id, :parent_id, :author_id

  def self.find_by_id( reply_id )
    reply_data = QuestionsDatabase.instance.get_first_row(<<-SQL, :reply_id => reply_id)
    SELECT
    *
    FROM
    replies
    WHERE
    id = :reply_id

    SQL
    Reply.new(reply_data)
  end

  def self.find_by_question_id
    replies_data = QuestionsDatabase.instance.execute(<<-SQL, :ques_id => self.question_id)
    SELECT
      *
    FROM
      replies
    WHERE
      question_id = :ques_id
    SQL

    replies_data.map { |reply| Reply.new(reply) }
  end

  def initialize( options = {} )
    @id, @question_id, @parent_id, @author_id = options.values_at(
    :id, :question_id, :parent_id, :author_id)
  end

end


class Like

  attr_accessor :user_id, :question_id

  def self.find_by_id( like_id )
    like_data = QuestionsDatabase.instance.get_first_row(<<-SQL, :like_id => like_id)
    SELECT
      *
    FROM
      question_likes
    WHERE
      id = :like_id
    SQL

    Like.new(like_data)
  end

  def initialize( options = {} )
    @id, @user_id, @question_id = options.values_at( :id, :user_id, :question_id )
  end

end
