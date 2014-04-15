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

    Like.new(like_data)
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

  def initialize( options = {} )
    @id, @user_id, @question_id = options.values_at( "id", "user_id", "question_id" )
  end

end