# frozen_string_literal: true
module Editor
  # A snapshot of a document's complete file contents (front matter and body).
  class Revision < Record
    attribute :document_id, :string
    attribute :content, :string
    attribute :label, :string
    attribute :major, :boolean, default: false

    validates :document_id, presence: true

    def self.for_document(document)
      where(document_id: document.id).reverse
    end

    def major? = major

    def display_label
      label.presence || (major? ? "Major revision" : "Revision")
    end
  end
end
