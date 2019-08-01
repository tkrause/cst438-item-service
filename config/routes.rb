Rails.application.routes.draw do
  resources :items, except: :new do
    collection do
      put :order
    end
  end
end
