FROM ruby:2.2.0

RUN mkdir /data
ADD ./ /app
WORKDIR /app
RUN bundle install

EXPOSE 80
VOLUME /data

ENTRYPOINT ["bundle", "exec", "ruby", "app.rb", "/data", "-p", "80", "-o", "0.0.0.0"]
