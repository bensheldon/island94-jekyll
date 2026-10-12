# frozen_string_literal: true
module Editor
  # A proofreading finding about a document. Findings are computed in the
  # browser (see proofread_controller.js), which sends each new set to the
  # server to store and render.
  #
  # A finding is identified across edits by its `key`, derived from its source,
  # rule, and problem text, so an ignored finding stays ignored.
  class Finding < Record
    STATUSES = %w[open ignored].freeze
    SOURCES = %w[harper ai].freeze

    attribute :document_id, :string
    attribute :key, :string
    attribute :source, :string
    attribute :rule, :string
    attribute :category, :string
    attribute :message, :string
    attribute :problem, :string
    attribute :start, :integer
    attribute :end, :integer
    attribute :suggestions, default: -> { [] }
    attribute :status, :string, default: "open"
    attribute :verdict, :string # Gemini Nano's review: "confirmed", "dismissed", or nil

    validates :document_id, :key, :source, :problem, presence: true
    validates :status, inclusion: { in: STATUSES }
    validates :source, inclusion: { in: SOURCES }

    def self.for_document(document)
      where(document_id: document.id).sort_by { |finding| [finding.start.to_i, finding.id] }
    end

    # Replaces the document's findings from `source` with `findings` (hashes
    # sent by the browser), keeping ignored findings ignored.
    def self.sync(document, source, findings)
      Store.synchronize do
        existing = where(document_id: document.id, source: source)
        ignored = existing.select(&:ignored?).to_set(&:key)
        existing.each(&:destroy)

        findings.each do |attrs|
          finding = new(
            **attrs.to_h.symbolize_keys.slice(:key, :rule, :category, :message, :problem, :start, :end, :suggestions, :verdict),
            document_id: document.id,
            source: source
          )
          finding.status = "ignored" if ignored.include?(finding.key)
          finding.suggestions = Array(finding.suggestions).map(&:to_s)
          finding.save! if finding.valid?
        end
      end
    end

    def dismissed_by_ai? = verdict == "dismissed"
    def confirmed_by_ai? = verdict == "confirmed"
    def ignored? = status == "ignored"
    def open? = status == "open"
  end
end
