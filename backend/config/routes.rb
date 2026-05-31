Rails.application.routes.draw do
  scope :api do
    get "schedule", to: "api/schedules#show"
    put "schedule", to: "api/schedules#update"
    delete "schedule/:appointment_id", to: "api/schedules#destroy"
  end

  frontend_index = Rails.root.join("public/frontend/index.html")
  if frontend_index.exist?
    root to: "spa#show"
    get "*path", to: "spa#show", constraints: lambda { |request|
      !request.path.start_with?("/api")
    }
  end
end
