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
  
  TWITTER_PAGE_SIZE = 100
  
  def initialize(email, password)
    @twitter = Twitter::Base.new(email, password)
  end
  
  def start
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

  def followers
    @followers ||= find_followers
  end
  
  def friends
    @friends ||= find_friends
  end

  private
  
    def follow(name)
      @twitter.create_friendship(name)
    end
    
    def find_followers(page = 1)
      f = @twitter.followers(:lite => true, :page => page).collect { |f| f.screen_name }
      return f if f.empty? || f.size < TWITTER_PAGE_SIZE
      f + find_followers(page + 1)
    end
    
    def find_friends(page = 1)
      f = @twitter.friends(:lite => true, :page => page).collect { |f| f.screen_name }
      return f if f.empty? || f.size < TWITTER_PAGE_SIZE
      f + find_friends(page + 1)
    end
end
