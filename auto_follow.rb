#!/usr/bin/env ruby

require 'rubygems'
require 'twitter'

# 
# Usage:
# follower = AutoFollower.new('admin@example.com', 'password')
# follower.start
# 
class AutoFollower
  
  def initialize(email, password)
    @twitter = Twitter::Base.new(email, password)
  end
  
  def start
    friends = @twitter.friends(true).collect { |f| f.screen_name }
    followers = @twitter.followers(true).collect { |f| f.screen_name }
    
    (followers - friends).each { |name| @twitter.create_friendship(name) }
  end

end
