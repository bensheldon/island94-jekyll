# frozen_string_literal: true
module Editor
  # One AI review of a document, running one or more checks in the background.
  class Review < Record
    STATUSES = %w[queued running succeeded failed].freeze

    attribute :document_id, :string
    attribute :pass_ids, default: -> { [] }
    attribute :pass_name, :string
    attribute :color, :string
    attribute :status, :string, default: "queued"
    attribute :created_count, :integer, default: 0
    attribute :error, :string
    attribute :cost_usd, :float
    attribute :started_at, :datetime
    attribute :finished_at, :datetime

    validates :document_id, :pass_ids, presence: true
    validates :status, inclusion: { in: STATUSES }

    def self.for_document(document)
      where(document_id: document.id)
    end

    def self.recent_for(document, limit: 5)
      for_document(document).last(limit)
    end

    # Starts a fresh review: earlier findings and reviews from these checks are
    # cleared first. Returns the cleared findings and the review.
    def self.enqueue(document, passes)
      cleared = clear(document, passes)
      name = passes.one? ? passes.first.name : "#{passes.size} checks"
      review = create!(document_id: document.id, pass_ids: passes.map(&:id), pass_name: name, color: passes.first.color)
      Reviewer.enqueue(review.id)
      [cleared, review]
    end

    # Holds the store lock so a running review can't write findings mid-clear
    # (see ReviewRunner).
    def self.clear(document, passes)
      slugs = passes.map(&:slug)
      ids = passes.map(&:id)
      Store.synchronize do
        for_document(document).each { |review| review.destroy if review.pass_ids.intersect?(ids) }
        document.highlights.select { |highlight| highlight.checks.intersect?(slugs) }.each(&:destroy)
      end
    end

    def passes
      Pass.all.select { |pass| pass_ids.include?(pass.id) }
    end

    def pending?
      %w[queued running].include?(status) && !interrupted?
    end

    # Still pending, but not being worked on by this process: the server restarted.
    def interrupted?
      %w[queued running].include?(status) && Store.active_reviews.exclude?(id)
    end

    def duration
      return unless started_at

      (finished_at || Time.current) - started_at
    end
  end
end
