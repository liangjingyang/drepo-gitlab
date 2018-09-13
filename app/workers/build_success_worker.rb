# frozen_string_literal: true

class BuildSuccessWorker
  include ApplicationWorker
  include PipelineQueue

  queue_namespace :pipeline_processing

  # rubocop: disable CodeReuse/ActiveRecord
  def perform(build_id)
    Ci::Build.find_by(id: build_id).try do |build|
      create_deployment(build) if build.has_environment?
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord

  private

  def create_deployment(build)
    CreateDeploymentService.new(build).execute
  end
end
