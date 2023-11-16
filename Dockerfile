FROM ruby:3.2.2

ENV LANG=C.UTF-8 \
  TZ=Asia/Tokyo

RUN apt-get update -qq && apt-get install -y postgresql-client libpq-dev
RUN curl -L https://fly.io/install.sh | sh

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install
COPY . /app

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

CMD ["rails", "server", "-b", "0.0.0.0"]