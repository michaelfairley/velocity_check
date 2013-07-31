# VelocityCheck

Lets you know if something is happening too often.

## Installation

Add this line to your application's Gemfile:

    gem 'velocity_check'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install velocity_check

## Usage

```ruby
SNEEZE_CHECK = VelocityCheck.new(
  :name => "sneeze",
  :limit => 10,
  :time_period => 600,
  :client => DALLI_CLIENT,
)

class Person
  def initialize(name)
    @name = name
  end

  def sneeze!
    if SNEEZE_CHECK.check(@name)
      puts "#{@name} has sneezed too much recently"
    end
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
