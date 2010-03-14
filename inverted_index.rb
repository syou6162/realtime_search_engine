# -*- coding: utf-8 -*-

require "word2id"
require "doc2id"
require "pp"
require 'tokyotyrant'
class InvertedIndex
  def initialize(opts)
    @rdb = TokyoTyrant::RDB::new
    @rdb.open(opts["host"], opts["port"])

    @word2id = opts["word2id"]
    @doc2id = opts["doc2id"]
  end
  def getDocs(word)
    result = []
    puts "word: #{word}"
    word.chars.each_cons(2).each{|item|
      sub_result = []
      puts "word: #{item.join}"
      puts "id: #{@word2id.getID(item.join, false)}"
      tmp = @rdb.get(@word2id.getID(item.join, false))
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
    @rdb.close
  end
end
