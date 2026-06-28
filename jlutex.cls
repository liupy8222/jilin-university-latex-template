
% The latest version of this license is in
%   https://www.latex-project.org/lppl.txt

\NeedsTeXFormat{LaTeX2e}[1995/12/01]
\ProvidesClass{jlutex}[2026/05/20 Jilin University bachelor document class]

\def\jlu@int@boolopt#1#2{
	\expandafter\newif\csname ifjlu@opt@#1\endcsname
	\@nameuse{jlu@opt@#1#2}
	\DeclareOption{#1}{\@nameuse{jlu@opt@#1true}}
	\DeclareOption{no#1}{\@nameuse{jlu@opt@#1false}}
}
% 处理文字编码
\newif\ifjlu@opt@gbk \jlu@opt@gbktrue
\DeclareOption{GBK}{\jlu@opt@gbktrue\PassOptionsToClass{GBK}{ctexbook}}
\DeclareOption{UTF8}{\jlu@opt@gbkfalse\PassOptionsToClass{UTF8}{ctexbook}}
%==============================================================
%=                    定义一些布尔变量作用开关                  =
%==============================================================
% 是否在标题标记中启用“\Uppercase”（有问题）。
\jlu@int@boolopt{uppermark}{false}
% 是否按学校规定修改字体。
\jlu@int@boolopt{pkufont}{true}
% 是否按学校规定修改脚注格式。
\jlu@int@boolopt{pkufoot}{true}
% 是否按学校规定调整间距。
\jlu@int@boolopt{pkuspace}{true}
% 是否使用一些常用设置来调整间距。
\jlu@int@boolopt{spacing}{true}
% 为目录添加PDF书签。
\jlu@int@boolopt{pdftoc}{true}
% 是否允许 `\spacialchap' 命令
\jlu@int@boolopt{spechap}{true}
% 是否自动为用户生成的PDF设置属性
% defined document information (author, title, etc.).
\jlu@int@boolopt{pdfprop}{true}
% 是否禁用一些旨在使样式不那么难看的违规。
\jlu@int@boolopt{ugly}{false}

% Pass all other options to `ctexbook' document class.
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{ctexbook}}
% Process all class options now.
\ProcessOptions\relax
% 防止fontspec（由xeCJK加载）干扰newtxpath。
\ifjlu@opt@pkufont
	\PassOptionsToPackage{no-math}{fontspec}
\fi
% 解决 `\lvert already defined' error. cf. <https://github.com/CTeX-org/ctex-kit/issues/454>.
\ifjlu@opt@pkufont
	\RequirePackage{amsmath}
\fi
% jlutex is 基于ctexbook; 默认字号是小四
% XeLaTeX 下使用 windows 字体集，使西文与数字默认走 Times New Roman。
\RequirePackage{iftex}
\ifxetex
	\LoadClass[zihao = -4]{ctexbook}[2014/03/06]
\else
	\LoadClass[zihao = -4]{ctexbook}[2014/03/06]
\fi

%==============================================================
%=                     加载Package                            =
%==============================================================
% 使生成的pdf在复制文字时不乱码,可直接用于查重
% \RequirePackage{cmap}
% 提供if语句，ctex 2.x no longer loads ifpdf and ifxetex by itself.
\RequirePackage{ifpdf, ifxetex}
% 提供`key = val'，用于给变量赋值
\RequirePackage{keyval}
% Graphics support.
\RequirePackage{graphicx}[1999/02/16]
% 提供页面尺寸设置功能
\RequirePackage{geometry}
% 提供页眉页脚脚注的支持
\RequirePackage{fancyhdr}
% 提供封面标题中的 `\uline'
\RequirePackage{ulem}
% `\AtEndOfClass' used to avoid `PDF destination not defined' with setspace.
\AtEndOfClass{\RequirePackage{hyperref}}
%两端对齐
\RequirePackage{ragged2e}
% % 提供调整字间距的
% \RequirePackage{letterspace}
\RequirePackage{expl3}

%==============================================================
%=                    根据条件启动相应的功能                   =
%==============================================================

\ifjlu@opt@gbk
	%\input{jlutex-gbk.def}
	\ifxetex
		% No support for XeLaTeX compilation in non-unicode encoding, i.e. GBK.
		\ClassError{jlutex}%
			{XeLaTeX compilation is not supported without UTF-8}%
			{%
				XeLaTeX compilation without UTF-8 is very problematic.\MessageBreak
				Therefore please use UTF-8 encoding for the LaTeX code.%
			}
	\fi
\else
	%\input{jlutex-utf8.def}
\fi

\ifjlu@opt@pkufont
	% 中文宋体等由 ctex 管理；西文与阿拉伯数字统一为 Times New Roman（新罗马）。
	\ifxetex
		\setmainfont{Times New Roman}
		\AtBeginDocument{%
		\csname ExplSyntaxOn\endcsname
		\csname msg_redirect_name:nnn\endcsname{xeCJK}{CJKfamily-redef}{none}%
		\csname ExplSyntaxOff\endcsname
		\setCJKfamilyfont{zhsong}{SimSun}[AutoFakeBold = true]%
		\setCJKfamilyfont{zhhei}{SimHei}[AutoFakeBold = true]%
		}%
		\DeclareRobustCommand{\sffamily}{\rmfamily}
	\else
		% pdfLaTeX 下 CJK 会把数字与字母一并嵌入中文字体；请改用 XeLaTeX 编译。
		% Option used to prevent newtxtext from manipulating footnote marks.
		\RequirePackage[defaultsups]{newtxtext}
	\fi
	\RequirePackage[cmintegrals, varg]{newtxmath}
\else
	% Provides `\Box' for originauth.tex if newtx is absent.
	\RequirePackage{latexsym}
\fi

\ifjlu@opt@pkufoot
	% Handle the `Unparsed material' issue with latex/dvipdfmx compilation.
	\unless\ifxetex\unless\ifpdf
		\newcommand*\pgfsysdriver{pgfsys-dvipdfm.def}
	\fi\fi
	% Circled text, cf. <https://tex.stackexchange.com/questions/7032/>.
	\RequirePackage{tikz}
	\newcommand*\jlu@int@circled[1]{%
		\scalebox{0.8}{\tikz[baseline = (char.base)]{
			\node[
				shape = circle, draw = black, minimum size = 1.25em, inner sep = 0pt
			] (char) {#1};
		}}%
	}
	% 使用带圆圈的数字作为脚注符号。 不影响标题页，但脚注很少用于论文封面
	\renewcommand*{\thefootnote}%
		{\protect\jlu@int@circled{\arabic{footnote}}}
	% Provides utility to modify footnote spacing.
	% Option used to make sure it does not render interleaf pages totally blank.
	\RequirePackage[cleardoublepage = current]{scrextend}
	% Set up footnote spacing: whole paragraph indent 2 ccwd, 0.5 ccwd after mark.
	\deffootnote{2\ccwd}{0pt}{\thefootnotemark\hspace{0.5\ccwd}}
\fi

\ifjlu@opt@pkuspace
	\linespread{1.5}\selectfont
	
	% 目录设置 缩进与行间距
	\RequirePackage[subfigure,titles]{tocloft}
	\setlength{\cftbeforechapskip}{0.4\baselineskip}
	\setlength{\cftbeforesecskip}{0.4\baselineskip}
	\setlength{\cftbeforesubsecskip}{0.4\baselineskip}
	\setlength{\cftsecindent}{\ccwd}
	\setlength{\cftsubsecindent}{2\ccwd}
	\setlength{\cftsubsubsecindent}{4\ccwd}
	% `caption' modifies font size and separator of captions.  `subcaption'
	% provides functions similar to `subfigure'/`subfig' but does not clash with
	% `tocloft'; it clashes with `subfigure'/`subfig', but the error message will
	% say they cannot be used simultaneously.
	\RequirePackage{caption, subcaption}
	\DeclareCaptionFont{cfive}{\rmfamily\zihao{5}}
	\DeclareCaptionLabelSeparator{quad}{\quad}
	\captionsetup{font = cfive, labelsep = quad}
\fi

\ifjlu@opt@spacing
	% Make spacing nicer in some situations (eg. footnotes and verbatims).
	\RequirePackage{setspace}
	% Remove superfluous spacing between footnotes.
	\setlength{\footnotesep}{0pt}
	% Lists often appear to be too sparse when items are just one or two lines
	% long. Here we cancel the extra vertical spacing between list items.
	% The list margin is adjusted due to Chinese typesetting traditions.
	\RequirePackage{enumitem}
	\setlist{nolistsep, leftmargin = 1.5\parindent}
\fi

\ifjlu@opt@spechap
	% This command is used to start a chapter without numbering, and correctly set
	% up the headers and footers in the chapter.
	\newcommand{\specialchap}[1]{%
		\chapter*{#1}\addcontentsline{toc}{chapter}{#1}
		\markboth{#1}{}\phantomsection%
	}
\fi

\AtBeginDocument{
	% Set up spacing for displayed formulae.
	\setlength{\abovedisplayskip}{\belowdisplayshortskip}
	\setlength{\belowdisplayskip}{\abovedisplayskip}

	\ifjlu@opt@pdftoc
		% Add PDF bookmark for table of contents.
		\let\jlu@tmp@tableofcontents\tableofcontents
		\renewcommand{\tableofcontents}{%
			\jlu@int@pdfmark{\contentsname}{contents}
			\jlu@tmp@tableofcontents%
			\thispagestyle{myheading}
		}
	\fi
	\addtocontents{toc}{\protect\thispagestyle{myheading}}{}


	\ifjlu@opt@pdfprop
		% Automatically generate properties for generated PDF.
		% Use English properties to avoid problems with character encodings.
		\newcommand*{\setpdfproperties}{%
			\hypersetup{
				pdftitle = {\@etitle},
				% pdfsubject = {JLU\ \ethesisname}, pdfkeywords = {\@ekeywords},pdfauthor = {\@eauthor}, 
			}%
		}
		% Set up the properties when generating the title page because the document
		% information should have been all defined before this.
		\let\jlu@tmp@maketitle\maketitle
		% NOTE: `\hypersetup' must appear before `\maketitle', otherwise it might
		% not act as expected.
		\renewcommand{\maketitle}{\setpdfproperties\jlu@tmp@maketitle}
	\fi
}

\def\jlu@int@infoitema#1{
	\@namedef{#1}##1{\@namedef{@#1}{##1}}
	\define@key{jlu@info}{#1}{\@nameuse{#1}{##1}}
}
\def\jlu@int@infoitemb#1{
	\define@key{jlu@info}{#1}{\@namedef{#1}{##1}}
}


% Set up document information entries.
\jlu@int@infoitema{ctitle} 		%论文的中文标题
\jlu@int@infoitema{etitle}			%论文的英文标题
\jlu@int@infoitema{cauthor}		%作者中文姓名
\jlu@int@infoitema{eauthor}		%作者英文姓名
\jlu@int@infoitema{studentid}		%学号
\jlu@int@infoitema{class}          %班级
\jlu@int@infoitema{date}			%日期
\jlu@int@infoitema{school}			%学院
\jlu@int@infoitema{cmajor}			%专业中文
\jlu@int@infoitema{emajor}			%专业英文
\jlu@int@infoitema{direction}		%研究方向
\jlu@int@infoitema{cmentor}		%导师中文姓名
\jlu@int@infoitema{ementor}		%导师英文姓名
\jlu@int@infoitema{mentortitle}    %导师职称
\jlu@int@infoitema{ckeywords}		%中文关键词
\jlu@int@infoitema{ekeywords}		%英文关键词
% \jlu@int@infoitema{cnumber}		%分类号
% \jlu@int@infoitema{UnitCode}		%单位代码
\jlu@int@infoitema{level}			%论文级别    （硕士/博士）
\jlu@int@infoitema{DegreeCategory} %学位类别	 （学术硕士/专业硕士/博士）
\jlu@int@infoitema{securitylevel}  %保密等级

\jlu@int@infoitemb{cuniversity}	%学校中文名	（define in *.def file）
\jlu@int@infoitemb{euniversity}	%学校英文名	（define in *.def file）
\jlu@int@infoitemb{cthesisname}	%论文种类中文（define in *.def file）
\jlu@int@infoitemb{ethesisname}	%论文种类英文（define in *.def file）
\jlu@int@infoitemb{cabstractname}	%摘要中文名	（define in *.def file）
\jlu@int@infoitemb{eabstractname}	%摘要英文名	（define in *.def file）
% Set up document information using the `key = value' grammar.
\newcommand*{\jlutexinfo}[1]{\setkeys{jlu@info}{#1}}

% 新增信息项的默认值，避免未设置时报错
\newcommand*{\@class}{}
\newcommand*{\@mentortitle}{}
% 定义logo的大小
\newcommand{\logowidth}{36mm}
% Set up page layout.
\geometry{
  a4paper,
  hmargin = 2.8cm,
  top = 2.8cm,
  bottom = 2.5cm,	
  headheight = 0.45cm,
  headsep = 1cm,
  footskip = 1.75cm % 这里大致对应规范中的“页脚 1.75cm”
}

% Set up chapter/section/... captions.
% The `*skip' values are not supposed to be modified by the `ugly' option:
% the actual style of the school's guide and Word template seem to be different
% from the written specification (when applied verbatim in LaTeX), and here the
% actual style is used.
\setcounter{secnumdepth}{3}
\setcounter{tocdepth}{2}
\ctexset{
	chapter = {
		name = {第~,~章},
		number = {\arabic{chapter}},
		numberformat = {\rmfamily},
		beforeskip = {-15bp}, afterskip = {12bp plus 0.2ex},
		nameformat = {}, titleformat = {}
	}, section =
		{beforeskip = {12bp plus 1ex minus 0.2ex}, afterskip = {5bp plus 0.2ex}},
	subsection =
		{beforeskip = {12bp plus 1ex minus 0.2ex}, afterskip = {5bp plus 0.2ex}},
	subsubsection =
		{beforeskip = {12bp plus 1ex minus 0.2ex}, afterskip = {5bp plus 0.2ex}}
}
\ifjlu@opt@ugly
	\ctexset{
		chapter = {format = {\songti\zihao{3}\bfseries\centering}},
		section = {format = {\songti\zihao{4}\bfseries}},
		subsection = {format = {\songti\zihao{-4}\bfseries}},
		subsubsection = {format = {\songti\zihao{-4}\bfseries}}
	}
\else
	\ctexset{
		chapter = {format = {\songti\zihao{3}\bfseries\centering}},
		section = {format = {\songti\zihao{4}\bfseries}},
		subsection = {format = {\songti\zihao{-4}\bfseries}},
		subsubsection = {format = {\songti\zihao{-4}\bfseries}}
	}
\fi

% `\MakeUppercase' works problematically.
% eg. it converts `\cite{ctex}' into `\cite{CTEX}'.
% This option can disable `\MakeUppercase' in left/right heading marks.
\ifjlu@opt@uppermark
	\def\jlu@int@setcase#1{#1}
\else
	% Code copied from fancyhdr's `\nouppercase', with the redefinition of
	% `\uppercase' dropped to avoid disrupting CJKutf8.
	% cf. <https://code.google.com/p/ctex-kit/issues/detail?id=147>.
	\def\jlu@int@setcase#1{%
		\let\MakeUppercase\relax%
		\expandafter\let\csname MakeUppercase \endcsname\relax%
		#1%
	}
\fi
% The actual page style setup.
 \fancypagestyle{plain}{
 	\fancyhf{}\renewcommand*{\headrulewidth}{0.75bp}
 	 %E偶数页，O奇数页，LCR左中右
 	\if@twoside
 		\fancyfoot[RO,LE]{\zihao{5}\normalfont{\thepage}}
 		\fancyhead[CE]{\zihao{5}\kaishu{\cuniversity\cthesisname}}
 		\fancyhead[CO]{\zihao{5}\kaishu\jlu@int@setcase{\leftmark}}
 	\else
 		\fancyfoot[R,R]{\zihao{5}\normalfont{\thepage}}
 		\fancyhead[C]{\zihao{5}\kaishu\jlu@int@setcase{\leftmark}}
 	\fi
 }
 \pagestyle{plain}

\fancypagestyle{myheading}{
	\fancyhf{}\renewcommand*{\headrulewidth}{0pt}
	 %E偶数页，O奇数页，LCR左中右
	\if@twoside
		\fancyfoot[RO,LE]{\zihao{5}\normalfont{\thepage}}
	\else
		\fancyfoot[R,R]{\zihao{5}\normalfont{\thepage}}
	\fi
}
\pagestyle{myheading}

% This places a bookmark pointing to somewhere near the page header;
% Result of simple `\chapter{...} \pdfbookmark{...}' does not look nice,
% because the bookmark will point to somewhere below the chapter mark.
\def\jlu@int@pdfmark#1#2{%
	\if@openright\cleardoublepage\else\clearpage\fi
	\pdfbookmark[0]{#1}{#2}%
}

% Usage: \jlu@int@fillinblank{(number of lines)}{(line width)}{(contents)}
\def\jlu@int@fillinblank#1#2#3{%
	\makebox[0pt][l]{\parbox[t]{#2}{\centering{#3}}}\mbox{}%
	\parbox[t]{#2}{%
		\newcount\jlu@tmp@linecount
		\jlu@tmp@linecount=#1
		\loop\ifnum\jlu@tmp@linecount>0
			% Fill specified space with underline on the bottom line. `\underline'
			% draws line on the baseline (not the bottom line), and this is why
			% `\uline' is used here instead.
			\ifnum\jlu@tmp@linecount=1
				\uline{\makebox[#2]{}}
			\else
				\uline{\makebox[#2]{}}\\
			\fi
		\advance\jlu@tmp@linecount by -1\relax
		\repeat%
	}%
}

% =================封面========================
	\renewcommand{\maketitle}{%
		\jlu@int@pdfmark{封面}{titlepage}
		\begin{titlepage}
			% 校徽
			\vspace*{-0.83mm}
			\hspace*{-1.13mm}
			\includegraphics[width = 28mm]{./jlu.png}

			\vspace*{-24pt}
			
			\begin{center}
				\begin{spacing}{1.0}
					\includegraphics[height = 67pt]{./jluname.png}\\
					\vskip 5pt
					\songti \fontsize{36}{32}\bfseries\selectfont{本科生毕业论文（设计）}\\
				\end{spacing}
			\end{center}
			\vskip 40pt
				
	\begin{center}
		\renewcommand{\arraystretch}{1.0}
		\setlength{\tabcolsep}{0em}
		% --- 上半部分：题目 ---
		\begin{tabular}{ll}
			% 左列：固定 4em 宽度（4个三号字）
			{\songti\zihao{3}\bfseries\makebox[4em][s]{中文题目}} &
			% 右列：统一修正为真正的 11.2cm 宽度
			\makebox[11.2cm][l]{% 
				\makebox[0pt][l]{% 
					\parbox[t]{11.2cm}{% 
						\setlength{\baselineskip}{32pt}
						\strut\rule[-4pt]{11.2cm}{0.5pt}\par
						\strut\rule[ 1pt]{11.2cm}{0.5pt}%
					}%
				}%
				\parbox[t]{11.2cm}{%
					\setlength{\baselineskip}{32pt}
					\heiti\zihao{3}\bfseries\strut \@ctitle \strut
				}%
			} \\[16pt]
			{\songti\zihao{3}\bfseries\makebox[4em][s]{英文题目}} &
			\makebox[11.2cm][l]{%
				\makebox[0pt][l]{%
					\parbox[t]{11.2cm}{%
						\setlength{\baselineskip}{32pt}
						\strut\rule[-4pt]{11.2cm}{0.5pt}\par
						\strut\rule[ 1pt]{11.2cm}{0.5pt}%
					}%
				}%
				\parbox[t]{11.2cm}{%
					\setlength{\baselineskip}{32pt}
					\rmfamily\zihao{-3}\bfseries\strut \@etitle \strut
				}%
			} \\
		\end{tabular}
	\end{center}

		\vskip 50pt 

	\begin{center}
		\renewcommand{\arraystretch}{1.0}
		\setlength{\tabcolsep}{0em} % 关键：同步去除下半部分的列间距
		% --- 下半部分：学生信息 ---
		% 改为 {ll}，与上半部分保持完全一致的列结构
		\begin{tabular}{ll}
		% --- 第1行 ---
		% 左列：4em
		{\songti\zihao{3}\bfseries\makebox[4em][s]{学生姓名}} &
		% 右列：内部相加 = 2.8+0.5+1.2+2.8+0.5+1.2+4.5 = 11.2cm
		\makebox[11.2cm][l]{%
			\underline{\makebox[2.6cm][c]{\songti\zihao{3}\bfseries\@cauthor}}%
			{\songti\zihao{3}\bfseries\makebox[1.2cm][s]{班\hfill 级}}%
			\underline{\makebox[2.6cm][c]{\songti\zihao{3}\bfseries\@class}}%
			{\songti\zihao{3}\bfseries\makebox[1.2cm][s]{学\hfill 号}}%
			\underline{\makebox[3.7cm][c]{\rmfamily\zihao{3}\bfseries\@studentid}}%
		} \\[16pt]
		
		% --- 第2行 ---
		{\songti\zihao{3}\bfseries\makebox[4em][s]{学\hfill 院}} &
		\underline{\makebox[11.2cm][c]{\songti\zihao{3}\bfseries\@school}} \\[16pt]
		
		% --- 第3行 ---
		{\songti\zihao{3}\bfseries\makebox[4em][s]{专\hfill 业}} &
		\underline{\makebox[11.2cm][c]{\songti\zihao{3}\bfseries\@cmajor}} \\[16pt]
		
		% --- 第4行 ---
		{\songti\zihao{3}\bfseries\makebox[4em][s]{指导教师}} &
		% 右列：内部相加 = 6.0+0.4+1.2+5.9 = 11.2cm
		\makebox[11.2cm][l]{%
			\underline{\makebox[5.0cm][c]{\songti\zihao{3}\bfseries\@cmentor}}%
			{\songti\zihao{3}\bfseries\makebox[1.2cm][s]{职\hfill 称}}%
			\underline{\makebox[5.0cm][c]{\songti\zihao{3}\bfseries\@mentortitle}}%
		} \\
		\end{tabular}
	\end{center}

        \vskip 55pt
        % 日期
        \begin{center}
            {\songti\zihao{3}\bfseries\@date}
\        \end{center}
        \vskip 1.5cm
    \end{titlepage}%
}
%================扉页======================
\newcommand{\innertitle}{
	\begin{flushleft}
		% For skip a space from the fancy
		\songti\zihao{4}{
		}
	\end{flushleft}
	\vskip 2.5cm
	\begin{center}
		\songti \zihao{3} {\@ctitle}\\
		\vskip 1.3cm
		\rmfamily \zihao{3} {\@etitle}
	\end{center}

	\vfill
	\begin{flushleft}
		% Slightly adjust the line skip when using new font size.
		\linespread{2}
		\songti\zihao{4}{
			{\hspace{1.5cm}作者姓名：\hspace{0.5cm}\@cauthor}		 		 \\%作者姓名
			{\hspace{1.5cm}专业名称：\hspace{0.5cm}\@cmajor} 	 \\%专业
			{\hspace{1.5cm}指导教师：\hspace{0.5cm}\@cmentor}		 	 	 \\%指导教师
			{\hspace{1.5cm}学位类别：\hspace{0.5cm}工学硕士}				  \\
			{\hspace{1.5cm}答辩日期：\hspace{1.5cm}年\hspace{1.3cm}月\hspace{1.3cm}日}						 \\%答辩日期
		}
	\end{flushleft}
	\vskip 2.5cm
}

%================投稿声明======================
\newenvironment{mcopyright}{%上定义：留白等待用户内容
	
}{%下定义
	\noindent
	\\

  \newcommand{\mycheckbox}[1]{\tikz{\path[draw=##1,fill=##1] (0,0) rectangle (10pt,10pt);}}
	\newcommand{\myuncheckbox}[1]{\tikz{\path[draw=##1,fill=white] (0,0) rectangle (10pt,10pt);}}
% 如果是硕士论文，使用下面这行
	论文级别：\mycheckbox{black} \@level  \hspace{1cm} \myuncheckbox{black} 博士 \\
% 如果是博士论文，使用下面这行
% 论文级别：\myuncheckbox{black} \@level  \hspace{1cm} \mycheckbox{black} 博士 \\

	学科专业：\@cmajor \\
	论文题目：\@ctitle\\
	\vskip 1.0cm
	\noindent
	作者签名： 　　　　　　　　　指导教师签名： \\
	
	\hspace{8.8cm}\hspace{2.0cm}年\hspace{1.0cm}月\hspace{1.0cm}日\\
	\vskip 1.0cm
	\vfill\noindent
	作者联系地址（邮编）：\@address\\
	作者联系电话：\@telephone\\
}

% ===============中文摘要======================
\newenvironment{cabstract}{%
	\jlu@int@pdfmark{摘要}{cabstract}
	%\chapter{}{}%\markboth{\cabstractname}
	\begin{center}
		\heiti\zihao{4}中文摘要
		% \heiti\zihao{3}\@ctitle
	\end{center}

	\parindent 2em
}{% Keywords at the bottom of the page.
	\vskip 0.5cm
	\noindent\textbf{关键词：}{\@ckeywords}%
}
%================英文摘要======================
\newenvironment{eabstract}{%
	\jlu@int@pdfmark{ABSTRACT}{eabstract}
	%\chapter{}{}%\markboth{\eabstractname}
	\begin{center}
		\zihao{4}ABSTRACT
		% \heiti\zihao{3}\@etitle
	\end{center}

	\parindent 2em
}{% Keywords at the bottom of the page.
	\vskip 0.5cm
	\noindent\textbf{Keywords: }{\@ekeywords}%
}
%================公式======================
\renewenvironment{equation}{%
	\incr@eqnum
	\mathdisplay@push
	\st@rredfalse \global\@eqnswtrue
	\mathdisplay{equation}%
	\hskip \textwidth minus \textwidth
}{%
	\leaders\hbox{}\hskip \textwidth minus \textwidth
	\endmathdisplay{equation}%
	\mathdisplay@pop
	\ignorespacesafterend
}
\endinput

