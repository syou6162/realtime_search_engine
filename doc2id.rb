# -*- coding: utf-8 -*-
require 'tokyotyrant'
class Doc2ID
  attr_accessor :doc2id, :id2doc
  def initialize(opts)
    @doc2id = Hash.new
    @id2doc = Array.new
    @rdb = TokyoTyrant::RDB::new
    @rdb.open(opts["host"], opts["port"])

    # traverse records
    @rdb.iterinit
    while doc = @rdb.iternext
      doc = doc.force_encoding('UTF-8')
      id = @rdb.get(doc).to_i
      @doc2id[doc] = id
      @id2doc[id] = doc
    end
  end
  def getID(doc, modify = true)
    if !@doc2id.key?(doc) && modify
      @doc2id[doc] = @doc2id.size
      @id2doc.push doc
      @rdb.put(doc, @doc2id[doc])
    end
    return @doc2id[doc]
  end
  def [](doc_id)
    return @id2doc[doc_id]
  end
  def close
    @rdb.close
  end
end
