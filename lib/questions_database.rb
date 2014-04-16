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
