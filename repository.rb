# -*- coding: utf-8 -*-
require "rubygems"
require 'sqlite3'

class Repository
  attr_accessor :dbh, :filename
  def initialize(filename)
    @filename = filename
    @dbh = SQLite3::Database.new(filename)
  end
  def close
    puts "db closed..."
    @dbh.close
  end
  def select
    # this returns enumerator
    @dbh.execute("select * from repository")
  end
  def save(key, value)
    sql = "insert into repository values (?, ?)"
    @dbh.execute(sql, key, value)
  end
end
