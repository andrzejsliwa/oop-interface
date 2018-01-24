# oop-interface - OOP interfaces for Ruby [![Build Status](https://travis-ci.org/andrzejsliwa/oop-interface.svg?branch=master)](https://travis-ci.org/andrzejsliwa/oop-interface)

The main idea behind of implementation of such gem, was limiting the scope.
For example when you are implementing Aggregate Root (following Domain Driven Design) 
in ActiveRecord, you would like to expose only public contract methods to ensure that 
Aggregate Root boundaries are not crossed by using directly relations or ActiveRecord methods.

This gem takes inspiration from https://github.com/shuber/interface and 
borrow some implementation details from it, extend it and modify available api.

Credits for [Sean Huber](https://github.com/shuber)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'oop-interface'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install interface

## Usage

Example usage:

      require "interface"

      module Order
        def submit; end
        def add_position(_position); end
      end
    
      module Saver
        def save; end
      end
    
      class OrderImpl
        include Interface
        implements Order, Saver
        def submit
          :submitted
        end
    
        def save(some: 5)
          "save #{some}"
        end
      end
      
      > OrderImpl.interfaces
      => [Order, Saver] 
       
      > OrderImpl.unimplemented_methods
      => {Order=>[:add_position]} 
       
      > saver = OrderImpl.new.as(Saver)
      => #<Saver:70247745038560> 
       
      > saver.submit
      NoMethodError: undefined method `submit' for #<Saver:70247745038560>
      
      > saver.save(some: 8)
      => "save 8"
      
      > OrderImpl.new.add_position
      NotImplementedError: OrderImpl needs to implement 'add_position' for interface Order
      
      > OrderImpl.new.is_a? Saver
      => true 
      
      > OrderImpl.new.is_a? Order
      => true
      
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/andrzejsliwa/interface.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
