class CallBook
 class CallConverter
  attr_reader :name, :theme, :output

  def initialize name, book
   @name = name
   @book = book
   @theme = "default"
  end

  def output output
   @output = output
  end

  def theme theme
   @theme = theme
  end

  def build
   raise "This method is not implement."
  end

  def validate
   if @book.src_files.count == 0
    raise "src_file is empty."
   end
  end

  def src_path file
   "#{Dir::getwd}/src/#{file}"
  end

  def tmp_path file
   "#{Dir::getwd}/tmp/#{file}"
  end

  def output_path file
   "#{Dir::getwd}/output/#{file}"
  end

  def copy_to_tmp files
   files.each { |file| 
    pn = Pathname.new tmp_path(file.file)
    FileUtils.mkdir_p(pn.dirname) unless FileTest.exist?(pn.dirname)

    unless FileTest.exist?(tmp_path(file.file)) && File::mtime(src_path(file.file)) <= File::mtime(tmp_path(file.file))
     puts "copy #{file.file} to tmp/".color :white
     FileUtils.copy_entry(src_path(file.file), tmp_path(file.file))
    end
   }
  end

  def cmd_exec cmd, args, option

   cmd_line = cmd + " " + args.map { |arg|
    Shellwords.shellescape(arg)
   }.join(" ")
   puts cmd_line.color :cyan
   stdout, stderr, status = Open3.capture3 cmd_line
   if option[:v] || status != 0
    puts stdout.color :green
   end
   if status != 0
    puts stderr.color :red
    puts "error!".color :red
    exit
   end
  end
 end

 class CallEpubConverter < CallConverter
  def build option
  end
 end

 class CallLatexConverter < CallConverter
  attr_reader :template

  def initialize name, book
   @vars = []
   @template = "template.tex"
   @filter = "pandoc-filter.rb"
   @hyoushi = []
   @urahyoushi = []
   super name, book
  end

  def documentclass param
   @vars << [:documentclass, param]
  end

  def classoption param
   @vars << [:classoption, param]
  end

  def prepartname param
   @vars << [:prepartname, param]
  end

  def postpartname param
   @vars << [:postpartname, param]
  end

  def prechaptername param
   @vars << [:prechaptername, param]
  end

  def postchaptername param
   @vars << [:postchaptername, param]
  end

  def template param
   @template = param
  end

  def filter param
   @filter = param
  end

  def vars_option
   result = []
   @vars.concat([[:book_name, @book.name]]).each { |v|
    result << "-V"
    result << "#{v[0]}=#{v[1]}"
   }
   result
  end

  def template_option
   if @template
    "--template=#{Dir::getwd}/theme/#{@theme}/#{@name}/#{@template}"
   else
    ""
   end
  end

  def filter_option
   if @filter
    "--filter=#{Dir::getwd}/theme/#{@theme}/#{@name}/#{@filter}"
   else
    ""
   end
  end

  def tex_path
   tmp_path(@book.name) + '.tex'
  end

  def json_path
   tmp_path(@book.name) + '.json'
  end

  def dvi_path
   tmp_path(@book.name) + '.dvi'
  end

  def pdf_path
   if @output
    output_path(@output) + '.pdf'
   else
    output_path(@book.name) + '.pdf'
   end
  end

  def extractbb_cmd
   "extractbb"
  end

  def _build_resource files, option
   copy_to_tmp files
   files.each { |file|
    xbb = File.dirname(tmp_path(file.file)) + "/" + File.basename(tmp_path(file.file), ".*") + ".xbb"
    unless FileTest.exist?(xbb) && File::mtime(tmp_path(file.file)) <= File::mtime(xbb)
     cmd_exec extractbb_cmd, [tmp_path(file.file)], option
    end
   }
  end

  def build_resource option
   _build_resource @book.resource_files, option
  end

  def pandoc_cmd
   "pandoc"
  end

  def pandoc_option option
   [
    "--chapters",
    "-f",
    "markdown_phpextra+hard_line_breaks+raw_tex",
    "-s",
    template_option,
    filter_option
   ]
  end

  def latex_cmd
   "uplatex"
  end

  def dvipdfm_cmd
   "dvipdfmx"
  end

  def build option
   if option['pandoc-json-output']
    cmd_exec pandoc_cmd, ["-o", json_path, "-t", "json"].concat(pandoc_option option).concat(vars_option).concat(@book.src_files.map{ |f| f.full_path }), option
   end
   cmd_exec pandoc_cmd, ["-o", tex_path, "-t", "latex"].concat(pandoc_option option).concat(vars_option).concat(@book.src_files.map{ |f| f.full_path }), option

   build_resource option

   f = open(tmp_path(@book.name + ".before_body.tex"), "w") do |io|
    io.puts @hyoushi.map { |h| h.latex @book, self} .join()
   end

   f = open(tmp_path(@book.name + ".after_body.tex"), "w") do |io|
    io.puts @urahyoushi.map { |h| h.latex @book, self }.join()
   end
   cmd_exec latex_cmd, ["-output-directory=#{tmp_path ""}", tex_path], option
   cmd_exec latex_cmd, ["-output-directory=#{tmp_path ""}", tex_path], option
   unless FileTest.exist?(pdf_path) && (File::mtime(dvi_path) <= File::mtime(pdf_path))
     cmd_exec "cd #{Shellwords.shellescape(tmp_path "")};#{dvipdfm_cmd}", ["-o", pdf_path, dvi_path], option
   end
  end
 end
 def epub_converter name, &block
  call = CallEpubConverter.new name, self
  if block
   call.instance_eval &block
  end
  call.validate
  @converters << call
 end

 def latex_converter name, &block
  call = CallLatexConverter.new name, self
  if block
   call.instance_eval &block
  end
  call.validate
  @converters << call
 end
end