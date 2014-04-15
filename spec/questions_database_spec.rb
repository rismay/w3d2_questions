require 'rspec'
require 'questions_database'

describe QuestionsDatabase do

end

describe Question do

  context '#find_by_id' do
    it 'responds to #find_by_id' do
      Question.should respond_to (:find_by_id)
    end

    it 'returns a Question object' do
      return_object = Question.find_by_id(1)
      expect(return_object.is_a?Question).to eq(true)
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
end

describe User do
  it 'responds to #find_by_id' do
    User.should respond_to (:find_by_id)
  end

  it 'returns a User object' do
    return_object = User.find_by_id(1)
    expect(return_object.is_a?User).to eq(true)
  end

  context 'Can find interesting stuff about himself' do

    let(:test_user) { User.find_by_id(1) }

    it 'responds to #authored_questions' do
      test_user.should respond_to (:authored_questions)
    end

    it 'responds to #authored_replies' do
      test_user.should respond_to (:authored_replies)
    end
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

describe Like do
  it 'responds to #find_by_id' do
    Like.should respond_to (:find_by_id)
  end

  it 'returns a Like object' do
    return_object = Like.find_by_id(1)
    expect(return_object.is_a?Like).to eq(true)
  end
end

