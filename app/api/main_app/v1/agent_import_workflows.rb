# frozen_string_literal: true

class MainApp::V1::AgentImportWorkflows < ApplicationAPI
  helpers do
    params :workflow_content do
      requires :book_prompt, type: String
      requires :author_prompt, type: String
    end

    params :pagination do
      optional :page, type: Integer, default: 1
      optional :per_page, type: Integer, default: 10
    end

    params :mock_authenticate do
      requires :user_id, type: Integer
    end

    def workflow
      @workflow ||= AgentImportWorkflow.find(params[:id])
    end

    def creator
      @creator ||= User.find(params[:user_id])
    end

    def render_workflow(import, paginate_option: {})
      paginated_result = paginate_option.present? ? import.paginated_result(paginate_option) : {}

      GoogleJsonResponse.render(
        import,
        serializer_klass: MainApp::V1::AgentImportWorkflowSerializer,
        custom_data: paginated_result
      )
    end
  end

  resource :workflows do
    params do
      use :pagination
    end

    desc 'Get all workflows'
    get do
      service = AgentImportWorkflows::GetService.new(params[:page], params[:per_page])
      workflows = service.call.data

      if service.success?
        render_workflow(
          workflows,
          paginate_option: {
            page: params[:page],
            per_page: params[:per_page]
          }
        )
      else
        error!(GoogleJsonResponse.render_error(service.errors), 400)
      end
    end

    desc 'Get an workflow'
    get ':id' do
      render_workflow(workflow)
    end

    params do
      use :workflow_content
      use :mock_authenticate
    end

    desc 'Create an workflow'
    post do
      service = AgentImportWorkflows::CreationService.new(creator, declared(params).except(:user_id))
      workflow = service.call.data

      if service.success?
        render_workflow(workflow)
      elsif service.has_error_class?(ActiveRecord::RecordNotFound)
        error!(GoogleJsonResponse.render_error(service.errors), 404)
      else
        error!(GoogleJsonResponse.render_error(service.errors), 400)
      end
    end

    params do
      use :workflow_content
      use :mock_authenticate
    end

    desc 'Update an workflow'
    put ':id' do
      service = AgentImportWorkflows::UpdateService.new(creator, params[:id], declared(params).except(:user_id))
      workflow = service.call.data

      if service.success?
        render_workflow(workflow)
      elsif service.has_error_class?(ActiveRecord::RecordNotFound)
        error!(GoogleJsonResponse.render_error(service.errors), 404)
      else
        error!(GoogleJsonResponse.render_error(service.errors), 400)
      end
    end

    params do
      use :mock_authenticate
    end

    desc 'Delete an workflow'
    delete ':id' do
      service = AgentImportWorkflows::DeletionService.new(creator, params[:id])
      service.call

      if service.success?
        status 204
      else
        error!(GoogleJsonResponse.render_error(service.errors), 404)
      end
    end
  end
end
