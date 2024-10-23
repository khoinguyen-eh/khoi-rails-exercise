# frozen_string_literal: true

class MainApp::V1::UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :gender, :date_of_birth

  def date_of_birth
    object.date_of_birth.iso8601
  end
end
