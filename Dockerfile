FROM ruby:3.0.4

RUN mkdir /monitor
WORKDIR /monitor

COPY Gemfile* ./
RUN bundle install

COPY lib/ lib/
COPY main.rb monitor params.yml ./

ENTRYPOINT ["bundle", "exec", "ruby main.rb"]
