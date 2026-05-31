class SpaController < ApplicationController
  def show
    render file: Rails.public_path.join("frontend", "index.html"), layout: false
  end
end
