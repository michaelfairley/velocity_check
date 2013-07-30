require 'spec_helper'

describe VelocityCheck do
  before(:all) do
    Dalli.logger.level = Logger::FATAL
  end

  let(:client) { Dalli::Client.new("127.0.0.1:#{ENV.fetch('BOXEN_MEMCACHED_PORT', 11211)}") }
  before(:each) { client.flush }

  let(:options) do
    {
      :name => rand(10**10).to_s,
      :limit => 10,
      :time_period => 2,
      :client => client,
    }
  end

  describe '.new' do
    it "constructs with the default options" do
      VelocityCheck.new(options)
    end

    it "requires a name" do
      expect do
        VelocityCheck.new(options.merge(:name => nil))
      end.to raise_error(ArgumentError, /:name is required/)
    end

    it "requires the name only have contain word characters" do
      expect do
        VelocityCheck.new(options.merge(:name => "hello!"))
      end.to raise_error(ArgumentError, /name/)
      expect do
        VelocityCheck.new(options.merge(:name => "hello"))
      end.to_not raise_error
    end

    it "requires a limit" do
      expect do
        VelocityCheck.new(options.merge(:limit => nil))
      end.to raise_error(ArgumentError, ":limit is required")
    end

    it "requires a time_period" do
      expect do
        VelocityCheck.new(options.merge(:time_period => nil))
      end.to raise_error(ArgumentError, ":time_period is required")
    end

    it "requires a client" do
      expect do
        VelocityCheck.new(options.merge(:client => nil))
      end.to raise_error(ArgumentError, ":client is required")
    end

    it "does not allow extra parameters" do
      expect do
        VelocityCheck.new(options.merge(:extra => "hello", :more => "junk"))
      end.to raise_error(ArgumentError, "Unknown options: extra, more")
    end
  end

  describe "#check" do
    subject(:checker) do
      VelocityCheck.new(options)
    end

    it "returns false until the limit has been passed" do
      10.times do
        checker.check("test").should be_false
      end
    end

    it "returns true after the limit has been passed" do
      10.times { checker.check("test") }
      checker.check("test").should be_true
    end

    it "returns false again after time_period has passed without a check" do
      10.times { checker.check("test") }
      checker.check("test").should be_true

      sleep 2

      checker.check("test").should be_false
    end

    it "returns true as long as a check happens within every time_limit after the threshold has been bassed" do
      10.times { checker.check("test") }
      10.times do
        checker.check("test").should be_true
        sleep 1
      end
    end

    it "returns false if time_period passes before the threshold check" do
      10.times { checker.check("test") }

      sleep 2

      checker.check("test").should be_false
    end

    it "isolates across the key passed in" do
      10.times { checker.check("test") }
      checker.check("test2").should be_false
      checker.check("test").should be_true
    end

    it "isolates across the name of the VelocityCheck" do
      checker2 = VelocityCheck.new(options.merge(:name => "Check2"))

      10.times { checker.check("test") }
      checker2.check("test").should be_false
      checker.check("test").should be_true
    end

    it "fails open if there's an error talking to memcached" do
      checker = VelocityCheck.new(options.merge(:client => Dalli::Client.new('127.0.0.1:5315')))

      100.times { checker.check("test").should be_false }
    end
  end
end
