FROM ruby:3.4.1

WORKDIR /my_rails_app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# Add any necessary build tools or libraries
RUN apt-get update -qq && apt-get install -y nodejs yarn postgresql-client

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]