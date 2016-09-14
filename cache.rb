#!/usr/bin/ruby
# encoding: utf-8

require 'redis'
require 'json'

class Cache
  @@thecache = Redis.new  

  def self.key(object)
    key = object.class.to_s+object.id.to_s 
    key += "." + object.serie.id.to_s if (defined? object.serie)
    return key   
  end

  def self.set(object)
    json_str = object.to_json
    @@thecache.setex self.key(object), 300, json_str
  end

  def self.get(key)
    return @@thecache.get(key)
  end
  
  def self.info()
    return @@thecache.info()
  end

end
