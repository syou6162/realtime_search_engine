# -*- coding: utf-8 -*-

require "word2id"
require "doc2id"
require 'tokyocabinet'

class InvertedIndex
  def initialize(opts)
    @hdb = TokyoCabinet::HDB.new # ハッシュデータベースを指定
    @hdb.open(opts["hdb_name"], opts["mode"])
    
    @word2id = opts["word2id"]
    @doc2id = opts["doc2id"]
  end
  def getDocs(word)
    result = []
    word.chars.each_cons(2).each{|item|
      sub_result = []
      tmp = @hdb.get(@word2id.getID(item.join, false))
      if !tmp.nil?
        tmp.unpack('C*').each{|doc_id| # バイナリを配列に
          sub_result.push doc_id
        }
      end
      result.push sub_result
    }

    return result.inject{|intersection, doc_id| 
      intersection & doc_id
    }.uniq
  end
  def close
    @hdb.close
  end
end
