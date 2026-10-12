# frozen_string_literal: true
module Editor
  class RevisionsController < ApplicationController
    before_action :set_document

    def index
      @revisions = @document.revisions
    end

    def show
      @revision = find_revision
    end

    # Flag the current state of the file as a milestone.
    def create
      @document.snapshot!(label: params[:label].presence, major: true)
      redirect_back_or_to document_path(@document), notice: "Revision saved."
    end

    def restore
      revision = find_revision
      @document.snapshot!(label: "Before restore")
      @document.content = revision.content
      @document.save!
      redirect_to document_path(@document), notice: "Restored revision from #{revision.created_at.to_fs(:short)}."
    end

    private

    def find_revision
      Revision.find(params.expect(:id)).tap do |revision|
        raise Record::RecordNotFound, "Revision not found" unless revision.document_id == @document.id
      end
    end
  end
end
