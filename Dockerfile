# syntax=docker/dockerfile:1

# Build the React frontend and copy it into backend/public/frontend for Rails to serve.
FROM node:20-alpine AS frontend

WORKDIR /app

COPY package.json package-lock.json ./
COPY frontend/package.json frontend/package-lock.json ./frontend/

RUN npm run frontend:install

COPY frontend ./frontend
RUN mkdir -p backend/public/frontend && npm run build

# Rails backend — pinned to Ruby 3.1.2 (see backend/.ruby-version and Gemfile).
FROM ruby:3.1.2-slim AS app

WORKDIR /app/backend

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      curl \
      libpq-dev \
      pkg-config && \
    rm -rf /var/lib/apt/lists/*

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development:test" \
    RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

COPY backend/Gemfile backend/Gemfile.lock ./
RUN bundle install

COPY backend ./
COPY --from=frontend /app/backend/public/frontend ./public/frontend

COPY bin/docker-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint

EXPOSE 3000

ENTRYPOINT ["docker-entrypoint"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
