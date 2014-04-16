require_relative 'questions_database'

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

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def self.most_followed(n)
    QuestionFollower.most_followed_questions(n)
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
