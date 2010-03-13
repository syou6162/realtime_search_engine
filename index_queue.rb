# -*- coding: utf-8 -*-

require 'tokyocabinet'

class IndexQueue
  def IndexQueue.callback(hdb)
    proc {
      puts "hdb closed..."
        hdb.close
    }
  end
  attr_accessor :queue
  def initialize(opts)
    puts opts
    index_queue_hdb_name = opts["hdb_name"]

    @hdb = TokyoCabinet::HDB.new # ハッシュデータベースを指定
    @hdb.open(index_queue_hdb_name, TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT)

    @word2id = opts["word2id"]
    @doc2id = opts["doc2id"]

    @queue = Array.new
    @n = 10
    ObjectSpace.define_finalizer(self, IndexQueue.callback(@hdb))
  end

  def add(tweet)
    @queue.push tweet
    if @queue.size > @n
      t = []
      @n.times{|i|
        t.push Thread.start{
          tweet = @queue.shift
          pp tweet
          doc_id = @doc2id.getID(tweet.url)
          tweet.text.chars.each_cons(2){|item|
            word_id = @word2id.getID(item.join)
            array = @hdb.get(word_id)
            if array.nil? # not stored yes
              array = [] 
            else 
              array = array.unpack('C*')
            end
            array.push doc_id
            @hdb.put(word_id, array.pack("c*"))
          }
        }
      }
      t.map{|t|t.join}
    end
  end
end
