require_relative 'questions_database'

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

  def average_karma
    p num_likes_data = QuestionsDatabase.instance.get_first_value(<<-SQL, :user_id => self.id)

    SELECT SUM(likes)/COUNT(question) as average_karma
    FROM
      (
      SELECT
        COUNT(ql.id) likes , q.title question
      FROM
        questions q JOIN question_likes ql ON q.id = ql.question_id
      WHERE
        q.author_id = :user_id
      GROUP BY
        ql.question_id

      )

    SQL

    num_likes_data
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

  def liked_questions
    QuestionLikes.liked_questions_for_user(self.id)
  end

  def initialize( options = {} )
    @id, @fname, @lname = options.values_at("id", "fname", "lname")
    self
  end

end
