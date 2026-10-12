# frozen_string_literal: true
Editor::Engine.routes.draw do
  root "documents#index"

  resources :passes, except: [:show]

  resources :documents, only: [:index, :show, :create, :update] do
    member do
      patch :autosave
    end

    resources :reviews, only: [:index, :create]

    resources :revisions, only: [:index, :show, :create] do
      member do
        post :restore
      end
    end

    resources :highlights, only: [:update]
  end
end
