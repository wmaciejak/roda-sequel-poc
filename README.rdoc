### Setup
Install dependencies:
```
bundle install
```

Prepare Database
```
rake dev_up
```

Run sidekiq:
```
bundle exec sidekiq -r ./app.rb -c 10
```

Run server:
```
puma
```

Load tests - https://gatling.io/
