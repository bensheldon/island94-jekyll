# frozen_string_literal: true
module Editor
  class ApplicationController < ActionController::Base
    layout "editor/application"

    before_action { head :not_found unless Rails.env.local? }

    rescue_from Document::NotFound, Record::RecordNotFound do |error|
      render plain: error.message, status: :not_found
    end

    private

    def set_document
      @document = Document.find(params[:document_id] || params[:id])
    end
  end
end
