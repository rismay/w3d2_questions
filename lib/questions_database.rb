require 'sqlite3'
require 'singleton'
require_relative 'question'

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
