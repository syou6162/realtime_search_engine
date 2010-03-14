# -*- coding: utf-8 -*-

require 'tokyocabinet'

class Indexer
  attr_accessor :queue
  def initialize(opts)
    @hdb = TokyoTyrant::RDB::new
    @hdb.open(opts["host"], opts["port"])
    @word2id = opts["word2id"]
    @doc2id = opts["doc2id"]
  end

  def add(tweet)
    doc_id = @doc2id.getID(tweet.url)
    tweet.text.chars.each_cons(2){|item|
      word_id = @word2id.getID(item.join)
      array = @hdb.get(word_id)
      if array.nil? # not stored yet
        array = [] 
      else 
        array = array.unpack('C*') # バイナリを配列に
      end
      array.push doc_id
      @hdb.put(word_id, array.pack("c*")) # 配列をバイナリに
    }
  end
  def close
    @hdb.close
  end
end
