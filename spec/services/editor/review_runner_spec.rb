# frozen_string_literal: true
require "rails_helper"

RSpec.describe Editor::ReviewRunner do
  let(:passes) { Editor::Pass.active.first(2) }
  let(:findings) do
    { "findings" => [{ "quote" => "very really actually", "comment" => "Empty words.", "suggestion" => "very", "severity" => "low", "checks" => passes.map(&:slug) }] }
  end

  it "creates merged findings from a single proofreading session" do
    with_temporary_post(filename: "2026-01-01-review-runner.md", body: "This is very really actually good.") do
      document = Editor::Document.find("2026-01-01-review-runner")
      review = Editor::Review.create!(document_id: document.id, pass_ids: passes.map(&:id), pass_name: "2 checks")
      llm = instance_double(Editor::Llm::Cli, last_cost_usd: 0.42)
      allow(llm).to receive(:structured).and_return(findings)

      described_class.new(review.id, llm: llm).call

      expect(llm).to have_received(:structured).with(a_string_including(passes.map(&:slug).join(", ")),
                                                     hash_including(agents: a_hash_including(*passes.map(&:slug)), tools: %w[Agent Read]))
      expect(Editor::Review.find(review.id)).to have_attributes(status: "succeeded", created_count: 1, cost_usd: 0.42)
      expect(document.highlights.sole).to have_attributes(quote: "very really actually", checks: passes.map(&:slug),
                                                          pass_name: passes.map(&:name).join(" · "))
    end
  end

  it "discards the findings of a review that was replaced while it ran" do
    with_temporary_post(filename: "2026-01-01-review-runner.md", body: "This is very really actually good.") do
      document = Editor::Document.find("2026-01-01-review-runner")
      review = Editor::Review.create!(document_id: document.id, pass_ids: passes.map(&:id), pass_name: "2 checks")
      llm = instance_double(Editor::Llm::Cli, last_cost_usd: 0.42)
      allow(llm).to receive(:structured) do
        Editor::Review.clear(document, passes) # the post is reviewed again while the model works
        findings
      end

      expect { described_class.new(review.id, llm: llm).call }.not_to raise_error
      expect(document.highlights).to be_empty
    end
  end
end
