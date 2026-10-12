# frozen_string_literal: true
module Editor
  # A finding from an AI review, anchored to a span of the post's text. The
  # editor keeps `quote` up to date as the author edits that span.
  class Highlight < Record
    COLORS = %w[yellow green blue pink purple orange].freeze
    STATUSES = %w[open accepted resolved ignored].freeze
    SEVERITIES = %w[low medium high].freeze

    attribute :document_id, :string
    attribute :anchor_id, :string, default: -> { SecureRandom.uuid }
    attribute :quote, :string
    attribute :original_quote, :string
    attribute :color, :string, default: "yellow"
    attribute :status, :string, default: "open"
    attribute :category, :string
    attribute :checks, default: -> { [] } # slugs of every check that flagged this text
    attribute :pass_name, :string
    attribute :severity, :string
    attribute :comment, :string
    attribute :suggestion, :string

    validates :document_id, :anchor_id, :quote, presence: true
    validates :color, inclusion: { in: COLORS }
    validates :status, inclusion: { in: STATUSES }

    def self.for_document(document)
      where(document_id: document.id)
    end

    def checks
      super.presence || [category].compact
    end

    def open? = status == "open"
    def edited? = original_quote.present? && original_quote != quote
  end
end
