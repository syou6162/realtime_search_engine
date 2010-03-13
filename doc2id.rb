# -*- coding: utf-8 -*-
require 'tokyocabinet'

class Doc2ID
  def Doc2ID.callback(hdb)
    proc {
      puts "hdb closed..."
      hdb.close
    }
  end
  attr_accessor :doc2id, :id2doc
  def initialize(hdb_name)
    @doc2id = Hash.new
    @id2doc = Array.new
    @hdb = TokyoCabinet::HDB.new # ハッシュデータベースを指定
    @hdb.open(hdb_name, TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT)

    # traverse records
    @hdb.iterinit
    while doc = @hdb.iternext
      doc = doc.force_encoding('UTF-8')
      id = @hdb.get(doc).to_i
      @doc2id[doc] = id
      @id2doc[id] = doc
    end
    ObjectSpace.define_finalizer(self, Word2ID.callback(@hdb))
  end
  def getID(doc)
    if !@doc2id.key?(doc)
      @doc2id[doc] = @doc2id.size
      @id2doc.push doc
      @hdb.put(doc, @doc2id[doc])
    end
    return @doc2id[doc]
  end
  def [](doc_id)
    return @id2doc[doc_id]
  end
end
