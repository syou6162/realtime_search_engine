# -*- coding: utf-8 -*-
require 'tokyocabinet'

class Word2ID
  attr_accessor :word2id, :id2word
  def initialize(opts)
    @word2id = Hash.new
    @id2word = Array.new
    @hdb = TokyoCabinet::HDB.new # ハッシュデータベースを指定
    @hdb.open(opts["hdb_name"], opts["mode"])
    
    # traverse records
    @hdb.iterinit
    while word = @hdb.iternext
      word = word.force_encoding('UTF-8')
      id = @hdb.get(word).to_i
      @word2id[word] = id
      @id2word[id] = word
    end
  end
  def getID(word, modify = true)
    if !@word2id.key?(word) && modify
      @word2id[word] = @word2id.size
      @id2word.push word
      @hdb.put(word, @word2id[word]) 
    end
    return @word2id[word]
  end
  def close
    @hdb.close
  end
end
