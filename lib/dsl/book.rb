require 'singleton'

class CallBook
 attr_reader :name, :src_files, :resource_files

 def initialize name
  @name = name
  @title = ""
  @author = ""
  @abstract = ""
  @src_files = []
  @resource_files = []
  @converters = []
 end


 def validate
 end

 def title *values
  # 引数が 2 つ以上ならエラー
  raise ArgumentError, "wrong number of arguments (#{ values.length} for 0..1)" if values.length > 1
  if values.empty?
   @title
  else
   @title = values[0]
  end
 end

 def author *values
  # 引数が 2 つ以上ならエラー
  raise ArgumentError, "wrong number of arguments (#{ values.length} for 0..1)" if values.length > 1
  if values.empty?
   @author
  else
   @author = values[0]
  end
 end
 def abstract *values
  # 引数が 2 つ以上ならエラー
  raise ArgumentError, "wrong number of arguments (#{ values.length} for 0..1)" if values.length > 1
  if values.empty?
   @abstract
  else
   @abstract = values[0]
  end
 end


 def build option
  puts "build #{@name} book.".color :green
  @converters.each { |c| 
   c.build option
  }
 end
end

def book name, &block
 call = CallBook.new name
 if block
  call.instance_eval &block
 end
 call.validate
 BookManager.instance.add call
end

class BookManager
 include Singleton
 def initialize
  @books = []
 end

 def add c
  @books << c
 end

 def build option
  @books.each { |book|
   if !option[:book] || option[:book] == book.name
    book.build option
   end
  }
 end
end

