# frozen_string_literal: true
module Editor
  class HighlightsController < ApplicationController
    before_action :set_document
    before_action :set_highlight

    # Resolve, ignore, or reopen a finding (Turbo Stream), or update its quote as
    # the author edits the text it's anchored to (JSON).
    def update
      @highlight.update!(**params.expect(highlight: %i[status quote]).to_h.symbolize_keys)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@highlight, partial: "editor/highlights/highlight", locals: { highlight: @highlight })
        end
        format.json { head :no_content }
      end
    end

    private

    def set_highlight
      @highlight = Highlight.find(params.expect(:id))
      raise Record::RecordNotFound, "Highlight not found" unless @highlight.document_id == @document.id
    end
  end
end
