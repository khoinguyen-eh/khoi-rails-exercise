# frozen_string_literal: true

module AiImplementation
  class BookAssistantService < BaseAssistantService
    DEFAULT_NUMBER_SAMPLE_VALUES = 3

    private

    def assistant_runnable?
      super
      return false unless success?

      unless workflow_item.book?
        add_error('Invalid workflow item status')
        return false
      end

      true
    end

    def schedule_next_poll
      Rails.logger.info "Rescheduled Book Assistant next polling with #{@params}"
      AiImplementation::AgentImportAssistantWorker.perform_in(
        ASSISTANT_POLLING_DURATION,
        @params['workflow_item_id'],
        @retry_counter,
        @params['thread_id'],
        @params['run_id']
      )
    end

    def update_assistant_thread_run_status!
      workflow_item.book_thread_run.update!(status: @assistant_run["status"])
    end

    def mark_current_assistant_started!
      Rails.logger.info "Book assistant mark as started with thread_id: #{@assistant['thread_id']}, run_id: #{@assistant['id']}"
      ActiveRecord::Base.transaction do
        agent_import_thread_run.assign_attributes(
          agent_import_workflow_item: @workflow_item,
          status: @assistant['status'],
          assistant_thread_id: @assistant['thread_id'],
          assistant_run_id: @assistant['id']
        )
        agent_import_thread_run.save!

        assistant_user_message = AgentImportMessage.find_or_initialize_by(
          agent_import_thread_run: agent_import_thread_run
        )
        assistant_user_message.role = 'user'
        assistant_user_message.assign_attributes(content: @prompt)
        assistant_user_message.save!
      end
    end

    def agent_import_thread_run
      @agent_import_thread_run ||= workflow_item.book_thread_run || workflow_item.build_book_thread_run
    end

    def assistant_response_text
      @assistant_response_text ||= @assistant_response['data'].first['content'].first['text']['value']
    end

    def prompt
      @prompt ||= workflow.book_prompt
    end

    def mark_current_assistant_run_completed!
      Rails.logger.info "Book assistant start marking completed in item #{@workflow_item.id}"
      Rails.logger.info "Successfully execute OpenAI API to retrieve output file content of Book assistant"
      ActiveRecord::Base.transaction do
        agent_import_thread_run.agent_import_messages.create!(
          role: 'assistant',
          content: assistant_response_text
        )

        book_json = JSON.parse(assistant_response_text)['book'].symbolize_keys.merge(
          user: user
        )
        book = Book.new(book_json)
        book.save!

        agent_import_thread_run.object_id = book.id
        agent_import_thread_run.save!

        Rails.logger.debug @assistant_response
      end
    end

    def execute_next_assistant_run
      Rails.logger.info "Book assistant ready to run Author Assistant in #{@workflow_item.id}"
      workflow_item.mark_author! if workflow_item.book?
      AiImplementation::AgentImportAssistantWorker.perform_in(ASSISTANT_SLEEP_DURATION, @workflow_item_id)
    end

    def assistant_id
      @assistant_id ||= ENV.fetch 'OPENAI_ASSISTANT_ID'
    end

    def build_assistant_user_messages
      default_user_message = {
        "role": "user",
        "content": prompt
      }
      default_user_message.merge!(@custom_message_params)

      @assistant_user_messages = {
        "messages": agent_import_thread_run.messages + [default_user_message]
      }
    end
  end
end
