# frozen_string_literal: true
module Editor
  class DocumentsController < ApplicationController
    before_action :set_document, only: %i[show update autosave]

    def index
      @documents = Document.all
    end

    def show
      @document.snapshot!(label: "Opened") if @document.revisions.empty?
      @passes = Pass.active
      @reviews = Review.recent_for(@document)
      @highlights = ordered_by_document_position(@document.highlights)
    end

    def create
      document = Document.create!(title: params.expect(:title))
      redirect_to document_path(document)
    rescue ArgumentError, RuntimeError => e
      redirect_to documents_path, alert: e.message
    end

    # Explicit save: writes the file, straightening quotes throughout, and
    # records a revision.
    def update
      if @document.update(document_params, straighten_quotes: true)
        @document.snapshot!(label: "Saved")
        redirect_to document_path(@document), notice: "Saved #{@document.project_filepath}."
      else
        redirect_to document_path(@document), alert: @document.errors.full_messages.to_sentence
      end
    end

    # Silent background save from the editor. No revision is recorded.
    def autosave
      if @document.update(document_params)
        head :no_content
      else
        render json: { errors: @document.errors.full_messages }, status: :unprocessable_content
      end
    end

    private

    # Sort highlights by where their quoted text appears in the document, so the
    # commentary sidebar reads top-to-bottom with the prose. Highlights whose text
    # is no longer present (stale) fall to the end.
    def ordered_by_document_position(highlights)
      text = @document.text
      highlights.sort_by.with_index do |highlight, i|
        index = text.index(highlight.quote)
        [index.nil? ? 1 : 0, index || 0, i]
      end
    end

    def document_params
      params.expect(document: %i[title front_matter body_html])
    end
  end
end
