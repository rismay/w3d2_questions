require_relative 'questions_database'

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
