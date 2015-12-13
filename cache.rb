#!/usr/bin/ruby
# encoding: utf-8

require 'redis'
require 'json'

class Cache
  @@thecache = Redis.new  

  def self.key(object)
    return object.class.to_s+object.id.to_s    
  end

  def self.set(object)
    json_str = object.to_json
    @@thecache.setex self.key(object), 300, json_str
  end

  def self.get(key)
    return @@thecache.get(key)
  end
end
