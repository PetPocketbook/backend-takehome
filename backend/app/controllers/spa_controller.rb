class SpaController < ApplicationController
  FRONTEND_INDEX = Rails.root.join("public/frontend/index.html")

  def show
    render html: File.read(FRONTEND_INDEX).html_safe, layout: false
  end
end
