# -*- coding: utf-8 -*-
require 'tokyocabinet'

class Word2ID
  def Word2ID.callback(hdb)
    proc {
      puts "hdb closed..."
      hdb.close
    }
  end
  attr_accessor :word2id, :id2word
  def initialize(hdb_name)
    @word2id = Hash.new
    @id2word = Array.new
    @hdb = TokyoCabinet::HDB.new # ハッシュデータベースを指定
    @hdb.open(hdb_name, TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT)

    # traverse records
    @hdb.iterinit
    while word = @hdb.iternext
      word = word.force_encoding('UTF-8')
      id = @hdb.get(word).to_i
      @word2id[word] = id
      @id2word[id] = word
    end

    ObjectSpace.define_finalizer(self, Word2ID.callback(@hdb))
  end
  def getID(word)
    if !@word2id.key?(word)
      @word2id[word] = @word2id.size
      @id2word.push word
      @hdb.put(word, @word2id[word]) 
    end
    return @word2id[word]
  end
end
