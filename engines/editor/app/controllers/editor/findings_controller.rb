# frozen_string_literal: true
module Editor
  # Proofreading runs in the browser, which sends its findings here to be
  # stored and rendered.
  class FindingsController < ApplicationController
    before_action :set_document

    # The browser sends JSON; don't also wrap it in a `finding` key.
    wrap_parameters false

    FINDING_ATTRIBUTES = [:key, :source, :rule, :category, :message, :problem, :start, :end, :verdict, { suggestions: [] }].freeze

    # Replaces the findings from one source (Harper or Gemini Nano).
    def create
      source = params.expect(:source)
      return head(:unprocessable_content) unless Finding::SOURCES.include?(source)

      findings = params.permit(:document_id, :source, findings: FINDING_ATTRIBUTES).fetch(:findings, [])
      Finding.sync(@document, source, findings)
      render_findings
    end

    # Ignores a finding.
    def update
      finding = Finding.find(params.expect(:id))
      finding.update!(status: params.expect(finding: [:status]).fetch(:status)) if finding.document_id == @document.id
      render_findings
    end

    # Shows all ignored findings again.
    def reset
      Finding.where(document_id: @document.id, status: "ignored").each { |finding| finding.update!(status: "open") }
      render_findings
    end

    private

    def render_findings
      render turbo_stream: turbo_stream.replace("findings", partial: "editor/findings/list", locals: { document: @document, findings: Finding.for_document(@document) })
    end
  end
end
