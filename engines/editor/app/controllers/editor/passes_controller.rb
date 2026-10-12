# frozen_string_literal: true
module Editor
  class PassesController < ApplicationController
    before_action :set_pass, only: %i[edit update destroy]

    def index
      @passes = Pass.all
    end

    def new
      @pass = Pass.new(position: (Pass.all.map(&:position).max || 0) + 1)
    end

    def edit
    end

    def create
      @pass = Pass.new(pass_params)
      if @pass.valid?
        @pass.save!
        redirect_to passes_path, notice: "Pass created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      @pass.assign_attributes(pass_params)
      if @pass.valid?
        @pass.save!
        redirect_to passes_path, notice: "Pass updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @pass.destroy
      redirect_to passes_path, notice: "Pass deleted."
    end

    private

    def set_pass
      @pass = Pass.find(params.expect(:id))
    end

    def pass_params
      params.expect(pass: %i[name slug color prompt position active])
    end
  end
end
