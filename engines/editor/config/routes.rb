# frozen_string_literal: true
Editor::Engine.routes.draw do
  root "documents#index"

  resources :documents, only: [:index, :show, :create, :update] do
    member do
      patch :autosave
    end

    resources :revisions, only: [:index, :show, :create] do
      member do
        post :restore
      end
    end

    # Proofreading runs in the browser, which sends its findings here.
    resources :findings, only: [:create, :update] do
      post :reset, on: :collection
    end
  end
end
