class CallBook
 class CallLatexConverter
  class CallLatexOp
   def initialize name
    @name = name
   end
   def validate
   end
   def latex book, converter
    ""
   end
  end

  class CallImgPageLatexOp < CallLatexOp
   def initialize name
    @topoffset = "0in"
    @leftoffset = "0in"
    super name
   end

   def topoffset param
    @topoffset = param
   end

   def leftoffset param
    @leftoffset = param
   end

   def file param
    @file = param
   end

   def latex book, converter
    <<"EOS"
\\enlargethispage{200truemm}%
\\thispagestyle{empty}%
\\vspace*{-1truein}
\\vspace*{-\\hoffset}
\\vspace*{-\\oddsidemargin}
\\vspace*{#{@leftoffset}}
\\noindent\\hspace*{-1in}\\hspace*{-\\voffset}\\hspace*{-\\topmargin}\\hspace*{-\\headheight}\\hspace*{-\\headsep}\\hspace*{#{@topoffset}}
\\includegraphics[width=\\paperheight,height=\\paperwidth]{#{@file}}
\\clearpage\n
EOS
   end
  end

  class CallEmptyPageLatexOp < CallLatexOp
   def initialize name
    @no_page_number = false
    super name
   end

   def no_page_number
    @no_page_number = true
   end

   def latex book, converter
    (@no_page_number ? "\\thispagestyle{empty}" : "")  + "　\\clearpage\n"
   end
  end

 class CallInnerTitlePageLatexOp < CallLatexOp
   def initialize name
    super name
   end

   def latex book, converter
    <<"EOS"
\\makeatletter
{
\\thispagestyle{empty}%
\\if@twocolumn\\@restonecoltrue\\onecolumn
\\else\\@restonecolfalse\\newpage\\fi
\\begin{minipage}<y>[c]{\\textheight}
\\begin{center}
\\vspace*{2.5cm}
{\\bf \\Huge #{book.title}}
\\end{center}
\\vspace*{1.5cm}
\\begin{center}
{\\Large #{book.creators.map { |c| c.name }.join " "}}
\\end{center}
\\vspace*{1.5cm}
\\begin{center}
#{book.description}
\\end{center}
\\end{minipage}
\\if@restonecol\\twocolumn\\else\\newpage\\fi
}%
\\makeatother
EOS
   end
  end

  def hyoushi_image_page name, &block
   call = CallImgPageLatexOp.new name
   if block
    call.instance_eval &block
   end
   call.validate
   @hyoushi << call
  end

  def hyoushi_empty_page name, &block
   call = CallEmptyPageLatexOp.new name
   if block
    call.instance_eval &block
   end
   call.validate
   @hyoushi << call
  end

  def hyoushi_inner_title_page name, &block
   call = CallInnerTitlePageLatexOp.new name
   if block
    call.instance_eval &block
   end
   call.validate
   @hyoushi << call
  end

  def urahyoushi_image_page name, &block
   call = CallImgPageLatexOp.new name
   if block
    call.instance_eval &block
   end
   call.validate
   @urahyoushi << call
  end

  def urahyoushi_empty_page name, &block
   call = CallEmptyPageLatexOp.new name
   if block
    call.instance_eval &block
   end
   call.validate
   @urahyoushi << call
  end

 end
end
