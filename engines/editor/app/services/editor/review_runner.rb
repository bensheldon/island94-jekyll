# frozen_string_literal: true
module Editor
  # Performs a queued Review in a background thread. The slow model call happens
  # outside of the Rails executor so that it never blocks code reloading (which
  # happens whenever a post is autosaved).
  #
  # A review is replaced (deleted) when the post is reviewed again. A replaced
  # review is treated as canceled: its results are discarded.
  class ReviewRunner
    def initialize(review_id, llm: nil)
      @review_id = review_id
      @llm = llm
    end

    def call
      Rails.application.executor.wrap do
        review = current_review or return
        review.update!(status: "running", started_at: Time.current)
        @proofreader = Proofreader.new(Document.find(review.document_id), review.passes, **{ llm: @llm }.compact)
      end
      return unless @proofreader

      findings = @proofreader.fetch_findings

      Rails.application.executor.wrap do
        # Hold the store lock so the review can't be replaced while its findings are written.
        Store.synchronize do
          review = current_review or next
          created = @proofreader.create_highlights(findings)
          review.update!(status: "succeeded", created_count: created, cost_usd: @proofreader.cost_usd, finished_at: Time.current)
        end
      end
    rescue StandardError => e
      Rails.application.executor.wrap do
        current_review&.update!(status: "failed", error: e.message.truncate(500), finished_at: Time.current)
      end
    end

    private

    def current_review
      Review.find(@review_id)
    rescue Record::RecordNotFound
      nil
    end
  end
end
