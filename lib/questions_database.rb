require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super("questions.db")
    self.results_as_hash = true
    self.type_translation = true
  end

  def self.execute(*args)
    QuestionsDatabase.instance.execute(*args)
  end

end

class DatabaseObject
  attr_accessor :id

end

class User < DatabaseObject
  attr_accessor :fname, :lname

  def self.new(options = {})
    @@cache ||= {}
    if @@cache.include?(options["id"])
      return @@cache[options["id"]]
    else
       new_user = allocate
      @@cache[options["id"]] = new_user.send(:initialize, options)
      return @@cache[options["id"]]
     end
  end

  def self.find_by_id( user_id )
    user_data = QuestionsDatabase.instance.get_first_row(<<-SQL, :user_id => user_id)
    SELECT
      *
    FROM
      users
    WHERE
      id = :user_id
    SQL

    user_data.nil? ? nil : User.new(user_data)
  end

  def self.find_by_name( fname, lname )
    user_params = {:fname => fname, :lname => lname}
    user_data = QuestionsDatabase.instance.get_first_row(<<-SQL, user_params)
    SELECT
    *
    FROM
    users
    WHERE
    fname = :fname, lname = :lname
    SQL

    user_data.nil? ? nil : User.new(user_data)
  end

  # get all questions belonging to User
  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def followed_questions
    QuestionFollower.followers_for_question_id(self.id)
  end


  def authored_replies
    Reply.find_by_user_id(self.id)
  end

  def initialize( options = {} )
    @id, @fname, @lname = options.values_at("id", "fname", "lname")
    self
  end

end


class Question < DatabaseObject
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
    author_data = QuestionsDatabase.instance.execute(<<-SQL, :auth_id => auth_id)
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

  def followers
    QuestionFollower.followers_for_question_id(self.id)
  end

  def initialize( options = {} )
    @id, @title, @body, @author_id =
      options.values_at("id", "title", "body", "author_id")
  end

end

class QuestionFollower < DatabaseObject
  attr_accessor :question_id, :user_id

  def self.find_by_id( qf_id )
    follower_data = QuestionsDatabase.instance.get_first_row(<<-SQL, :qf_id => qf_id)
    SELECT
    *
    FROM
    question_followers
    WHERE
    :qf_id = id
    SQL

    QuestionFollower.new(follower_data)
  end

  def self.followers_for_question_id( q_id )
    followers_data = QuestionsDatabase.instance.execute(<<-SQL, :q_id => q_id)
    SELECT
      users.*
    FROM
      question_followers JOIN users
      ON users.id = user_id
    WHERE
      question_id = :q_id
    SQL

    followers_data.map { |user| User.new(user) }

  end

  def self.followed_questions_for_user_id( user_id )
    followed_questions_data = QuestionsDatabase.instance.execute(<<-SQL, :user_id => user_id)
    SELECT
      questions.*
    FROM
      questions JOIN question_followers
      ON questions.id = question_id
    WHERE
      :user_id = question_followers.user_id
    SQL

    followed_questions_data.map { |question| Question.new(question) }

  end

  def self.most_followed_questions(n)
    followed_questions_data = QuestionsDatabase.instance.execute(<<-SQL, :num_questions => n)
    SELECT
    questions.*
    FROM
      question_followers JOIN questions
      ON question_id = questions.id
    GROUP BY question_id
    ORDER BY COUNT(user_id) DESC
    LIMIT :num_questions
    SQL

    followed_questions_data.map { |question| Question.new(question) }

  end


  def initialize( options = {} )
    @id, @question_id, @user_id = options.values_at("id", "question_id", "user_id")
  end

end


class Reply < DatabaseObject

  attr_accessor :question_id, :parent_id, :author_id, :author

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

  def self.find_by_user_id(user_id)
    user_replies = QuestionsDatabase.instance.execute(<<-SQL, :user_id => user_id)
    SELECT
      *
    FROM
      replies
    WHERE
      :user_id = author_id
    SQL

    user_replies.map { |reply| Reply.new(reply) }
  end

  def author
    @author ||= User.find_by_id(self.author_id)
  end

  def question
    Question.find_by_id(self.question_id)
  end

  def parent_reply
    Reply.find_by_id(self.parent_id)
  end

  def child_replies
    replies = QuestionsDatabase.execute(<<-SQL, :parent_object_id => self.id)
    SELECT
      *
    FROM
      replies
    WHERE
      :parent_object_id = parent_id
    SQL

    replies.map { |reply| Reply.new(reply) }
  end

  def initialize( options = {} )
    @id, @question_id, @parent_id, @author_id = options.values_at(
      "id", "question_id", "parent_id", "author_id"
    )
  end

end

class Like < DatabaseObject
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
    @id, @user_id, @question_id = options.values_at( "id", "user_id", "question_id" )
  end

end