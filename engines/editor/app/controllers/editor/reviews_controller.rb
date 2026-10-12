# frozen_string_literal: true
module Editor
  # Editing passes run in the background (see Editor::Reviewer). The editor
  # polls #index while any are pending to receive new highlights as they finish.
  class ReviewsController < ApplicationController
    before_action :set_document

    def index
      after = params[:after].to_i
      @new_highlights = @document.highlights.select { |highlight| highlight.id > after }
      render turbo_stream: [
        review_panel_stream,
        *@new_highlights.map { |highlight| turbo_stream.append("commentary_list", partial: "editor/highlights/highlight", locals: { highlight: highlight, arriving: true }) },
        (turbo_stream.remove("commentary_empty") if @new_highlights.any?),
      ].compact
    end

    def create
      passes = params[:pass_id] == "all" ? Pass.active : Pass.where(id: params[:pass_id].to_i)
      return head(:unprocessable_content) if passes.empty?

      cleared, = Review.enqueue(@document, passes)
      render turbo_stream: [review_panel_stream, *cleared.map { |highlight| turbo_stream.remove(highlight) }]
    end

    private

    def review_panel_stream
      turbo_stream.replace("review_panel", partial: "editor/reviews/panel", locals: { document: @document, reviews: Review.recent_for(@document) })
    end
  end
end
