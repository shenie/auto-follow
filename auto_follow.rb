#!/usr/bin/env ruby

require 'rubygems'
gem "twitter", '>=0.2.6'
require 'twitter'
require 'hpricot'

# 
# Usage:
# follower = AutoFollower.new('admin@example.com', 'password')
# follower.start
# follower.stalk('cincinnati')
# 
class AutoFollower
  
  def initialize(email, password)
    @twitter = Twitter::Base.new(email, password)
  end
  
  def start
    followers = @twitter.followers(true).collect { |f| f.screen_name }
    
    (followers - friends).each { |name| follow(name) }
  end

  def stalk(query, page = 1)
    doc = Hpricot(open("http://twitter.com/search/users?q=#{query}&page=#{page}"))
    names = doc.search(".screen_name span").collect { |d| d.innerHTML }
    return if names.empty?
    (names - friends).each { |name| follow(name) }
    page = page + 1
    stalk(query, page)
  end

  private
  
    def follow(name)
      @twitter.create_friendship(name)
    end
    
    def friends
      @friends ||= @twitter.friends(true).collect { |f| f.screen_name }
    end
end
