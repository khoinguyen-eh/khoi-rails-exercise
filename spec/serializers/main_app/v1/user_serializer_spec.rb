# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MainApp::V1::UserSerializer, type: :serializer do
  let(:current_time) { Time.zone.now }
  let(:user) {
    create(
      :user,
      first_name: 'John',
      last_name: 'Doe',
      email: 'john.doe@example.com',
      gender: true,
      date_of_birth: current_time
    ) }
  let(:serializer) { described_class.new(user) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer).as_json }

  it 'serializes the user id' do
    expect(serialization[:id]).to eq(user.id)
  end

  it 'serializes the user first name' do
    expect(serialization[:first_name]).to eq('John')
  end

  it 'serializes the user last name' do
    expect(serialization[:last_name]).to eq('Doe')
  end

  it 'serializes the user email' do
    expect(serialization[:email]).to eq('john.doe@example.com')
  end

  it 'serializes the user gender' do
    expect(serialization[:gender]).to eq(true)
  end

  it 'serializes the user date of birth' do
    expect(serialization[:date_of_birth]).to eq(current_time.iso8601)
  end
end
