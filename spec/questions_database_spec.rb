require 'rspec'

require 'question'
require 'user'
require 'question_follower'
require 'questions_database'
require 'question_like'

describe QuestionsDatabase do

end

describe Question do

  context '#find_by_id' do
    it 'responds to #find_by_id' do
      Question.should respond_to (:find_by_id)
    end

    context 'Introspects' do
      let(:test_question) { Question.find_by_id(1) }

      it 'returns a Question object' do
        expect(test_question.is_a?Question).to eq(true)
      end

      it 'returns a Question object' do
        expect(test_question.id).to eq(1)
      end

      it 'knows who follows it' do
        follower = User.find_by_id(2)
        expect(test_question.followers[0]).to eq(follower)
      end

    end

    context 'Most Liked questions' do
      it 'returns a cool question' do
        expect(Question.most_liked(1).first.id).to eq(1)
      end
    end
  end

end

describe QuestionFollower do
  it 'responds to #find_by_id' do
    QuestionFollower.should respond_to (:find_by_id)
  end

  it 'returns a Question object' do
    return_object = QuestionFollower.find_by_id(1)
    expect(return_object.is_a?QuestionFollower).to eq(true)
  end

  context '#followers_for_question_id' do
    let(:returned_arr) { QuestionFollower.followers_for_question_id( 1 ) }
    it 'responds to #followers_for_question_id' do
      QuestionFollower.should respond_to(:followers_for_question_id)
    end

    it 'returns an array of Users' do
      expect(returned_arr).to be_a(Array)
    end

    it 'returns the appropriate number of Questions' do
      expect(returned_arr.count).to eq(1)
    end
  end

  context '#followed_questions_for_user_id' do
    let(:returned_arr) { QuestionFollower.followed_questions_for_user_id( 1 ) }

    it 'responds to #followed_questions_for_user_id' do
      QuestionFollower.should respond_to(:followed_questions_for_user_id)
    end

    it 'returns an array of Questions' do
      expect(returned_arr).to be_a(Array)
    end

    it 'returns the appropriate number of Questions' do
      expect(returned_arr.count).to eq(1)
    end
  end

  context '::most_followed_questions' do
    let(:returned_arr) { QuestionFollower.most_followed_questions( 1 ) }

    it 'fetches the n most followed questions' do
      expect(returned_arr.count).to eq(1)
    end

    it 'resulted in a Question object' do
      expect(returned_arr.first).to be_a(Question)
    end

  end

end

describe User do
  it 'responds to #find_by_id' do
    User.should respond_to (:find_by_id)
  end

  it 'returns a User object' do
    return_object = User.find_by_id(1)
    expect(return_object.is_a?User).to eq(true)
  end

  it 'returns the corrent User' do
    return_object = User.find_by_id(1)
    expect(return_object.id).to eq(1)
  end

  context 'Can find interesting stuff about himself' do

    let(:test_user) { User.find_by_id(1) }

    it 'responds to #authored_questions' do
      test_user.should respond_to (:authored_questions)
    end

    it 'responds to #authored_replies' do
      test_user.should respond_to (:authored_replies)
    end

    it 'knows his karma' do
      test_user.average_karma
    end

    # it 'knows both users karma' do
    #   User.find_by_id( 2 ).average_karma
    # end

  end
end

describe Reply do
  it 'responds to #find_by_id' do
    Reply.should respond_to (:find_by_id)
  end

  it 'returns a Reply object' do
    return_object = Reply.find_by_id(1)
    expect(return_object.is_a?Reply).to eq(true)
  end
end

describe QuestionLike do
  it 'responds to #find_by_id' do
    QuestionLike.should respond_to (:find_by_id)
  end

  it 'returns a Like object' do
    return_object = QuestionLike.find_by_id(1)
    expect(return_object.is_a?QuestionLike).to eq(true)
  end

  context '#num_likes_for_question_id' do

    it 'responds to #num_likes_for_question_id' do
      QuestionLike.should respond_to (:num_likes_for_question_id)
    end

    it 'returns a number' do
      num_likes = QuestionLike.num_likes_for_question_id( 1 )
      expect( num_likes ).to be_a Integer
    end
  end


  context '#likers_for_question_id' do
    let(:likers) { QuestionLike.likers_for_question_id( 1 ) }

    it 'returns an array' do
      expect(likers).to be_a(Array)
    end

    it 'contains QuestionLike objects' do
      expect(likers.first).to be_a(User)
    end

  end

  context '#liked_questions_for_user_id(user_id)' do
    let(:questions) { QuestionLike.liked_questions_for_user(1) }

    it 'returns an array' do
      expect(questions).to be_a(Array)
    end

    it 'contains QuestionLike objects' do
      expect(questions.first).to be_a(Question)
    end

  end

end

