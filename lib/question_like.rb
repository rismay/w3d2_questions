require_relative 'questions_database'

class QuestionLike < DatabaseObject
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

    QuestionLike.new(like_data)
  end

  def self.likers_for_question_id(question_id)
    likers = QuestionsDatabase.execute(<<-SQL, :q_id => question_id)
    SELECT
      users.*
    FROM
      question_likes JOIN users ON (user_id = users.id)
    WHERE
      :q_id = question_id
    SQL

    likers.map {|liker| User.new(liker) }
  end

  def self.liked_questions_for_user(user_id)
    interesting_questions = QuestionsDatabase.execute(<<-SQL, :user_id => user_id)
    SELECT
      questions.*
    FROM
      question_likes JOIN questions ON (question_id = questions.id)
    WHERE
      :user_id = user_id
    SQL

    interesting_questions.map { |question| Question.new(question) }
  end

  def self.num_likes_for_question_id(question_id)
    num_likes_data = QuestionsDatabase.instance.get_first_row(<<-SQL, :question_id => question_id)
    SELECT
      COUNT(user_id) AS likes
    FROM
      question_likes
    WHERE
      question_id = :question_id
    GROUP BY
      question_id
    SQL

    num_likes_data["likes"].to_i
  end

  def self.most_liked_questions(n)
    cool_questions = QuestionsDatabase.execute(<<-SQL, :num_questions => n)
    SELECT
    questions.*
    FROM
      question_likes JOIN questions
      ON question_id = questions.id
    GROUP BY question_id
    ORDER BY COUNT(user_id) DESC
    LIMIT :num_questions
    SQL

    cool_questions.map { |data| Question.new(data) }
  end

  def likers
    QuestionLike.likers_for_question_id(self.id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(self.id)
  end

  def initialize( options = {} )
    @id, @user_id, @question_id = options.values_at( "id", "user_id", "question_id" )
  end

end