# NatsListener

[![Maintainability](https://api.codeclimate.com/v1/badges/8d3fc10f0adfda052efb/maintainability)](https://codeclimate.com/github/BEaStia/nats_listener/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/8d3fc10f0adfda052efb/test_coverage)](https://codeclimate.com/github/BEaStia/nats_listener/test_coverage)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nats_listener'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nats_listener

## Usage

For usage in your project we offer:

1. Create `initializer.rb` or manually call `NatsListener.current.establish_connection(service_name: [YOUR SERVICE NAME], servers: [NATS_SERVERS_URLS])`
2. For publishing you can use `NatsListener.current.publish` serializing message with two strategies(`protobuf` and `json`).
3. For receiving messages we offer subscribers

#### Protobuf strategy
```ruby
2.3.3 :006 > m = NatsListener::NatsMessage.new(sender_service_name: 'ololo', receiver_action_name: 'ololo1', receiver_action_parameters:[1,2,3].map(&:to_s), message_timestamp: Time.now.utc.to_i, transaction_id: 'unique')
 => #<NatsListener::NatsMessage sender_service_name="ololo" receiver_action_name="ololo1" receiver_action_parameters=["1", "2", "3"] message_timestamp=1538902717 transaction_id="unique"> 
2.3.3 :007 > m.serialize
 => "\n\x05ololo\x12\x06ololo1\x1A\x011\x1A\x012\x1A\x013 \xBD\x95\xE7\xDD\x05*\x06unique" 
```

#### Json strategy

```ruby
2.3.3 :009 > m = NatsListener::Message.new({action: 'ololo'})
 => #<NatsListener::Message:0x007ff1869a3628 @message={:publisher=>nil, :timestamp=>2018-10-07 09:00:29 UTC, :message_id=>"7dfc4de9-d920-4cc1-8cfe-5e85f7fb855d", :data=>{:action=>"ololo"}}> 
2.3.3 :010 > m.to_json
 => "{\"publisher\":service1,\"timestamp\":\"2018-10-07T09:00:29.133Z\",\"message_id\":\"7dfc4de9-d920-4cc1-8cfe-5e85f7fb855d\",\"data\":{\"action\":\"ololo\"}}" 
```

### Creating client
```ruby
NatsListener::Client.current = NatsListener::Client.new(
  logger: Ougai::Logger.new(STDOUT),
  skip: false,
  catch_errors: true,
  catch_provider: Rollbar
)
```
All arguments are optional.
`logger` - logger that you can pass to application. It will be called to debug messages.
`skip` - skip calls. Useful for tests
`catch_errors` - catch errors, log them and pass to `catch_provider`
`catch_provider` - provider that is called when error occurs, e.g. Rollbar.

### Subscribers

For using subscribers we offer one quite simple way:
1. Create `subscribers` folder.
2. Create your own subscriber derived from `NatsListener::Subscriber` 
3. Load and subscribe all subscribers, e.g.
```ruby
NatsListener::Client.current = NatsListener::Client.new(
  logger: Ougai::Logger.new(STDOUT),
  skip: false,
  catch_errors: true,
  catch_provider: Rollbar
)
NatsListener::Client.current.establish_connection(service_name: [YOUR SERVICE NAME], servers: [NATS_SERVERS_URLS])
path = Rails.root.join('app', 'subscribers', '*.rb')
Dir.glob(path) do |entry|
  entry.split('/').last.split('.').first.camelize.constantize.new.subscribe
end
```
4. ???
5. PROFIT

### NB!
Right now nats functionality is proved to work aside of Puma workers because of the conflicts between `puma` and `nats-pure` gems.


# TODO:
1. Add nats-streaming subscribers
2. Add usage of nats-streaming for calls


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/beastia/nats_listener. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the NatsListener project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/beastia/nats_listener/blob/master/CODE_OF_CONDUCT.md).
