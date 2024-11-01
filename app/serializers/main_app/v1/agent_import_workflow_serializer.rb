# frozen_string_literal: true

class MainApp::V1::AgentImportWorkflowSerializer < ActiveModel::Serializer
  attributes :id, :status, :book_prompt, :author_prompt
end
