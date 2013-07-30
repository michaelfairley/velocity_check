require "velocity_check/version"

class VelocityCheck
  def initialize(options)
    raise ArgumentError, ":name is required" unless options[:name]
    raise ArgumentError, ":name must only contain letters, numbers, and underscore" unless options[:name] =~ /\A\w+\z/
    raise ArgumentError, ":limit is required" unless options[:limit]
    raise ArgumentError, ":time_period is required" unless options[:time_period]
    raise ArgumentError, ":client is required" unless options[:client]

    known_options = [:name, :limit, :time_period, :client]
    unknown_options = options.keys - known_options
    raise ArgumentError, "Unknown options: #{unknown_options.join(', ')}"  unless unknown_options.empty?

    @name = options[:name]
    @client = options[:client]
    @time_period = options[:time_period]
    @limit = options[:limit]
  end

  def check(key)
    full_key = "#{@name}_#{key}"

    # It would nice if we could incr + touch, but touch is buggy
    # in most versions of memecached (and doesn't even exist in
    # debian squeeze's version).
    previous = @client.get(full_key) || 0
    @client.set(full_key, previous + 1, @time_period)

    previous >= @limit
  end
end
