# -*- coding: utf-8 -*-
require 'tokyotyrant'
class Word2ID
  attr_accessor :word2id, :id2word
  def initialize(opts)
    @word2id = Hash.new
    @id2word = Array.new
    @rdb = TokyoTyrant::RDB::new
    @rdb.open(opts["host"], opts["port"])

    # traverse records
    @rdb.iterinit
    while word = @rdb.iternext
      word = word.force_encoding('UTF-8')
      id = @rdb.get(word).to_i
      @word2id[word] = id
      @id2word[id] = word
    end
  end
  def getID(word, modify = true)
    if !@word2id.key?(word) && modify
      @word2id[word] = @word2id.size
      @id2word.push word
      @rdb.put(word, @word2id[word]) 
    end
    return @word2id[word]
  end
  def close
    @rdb.close
  end
end
