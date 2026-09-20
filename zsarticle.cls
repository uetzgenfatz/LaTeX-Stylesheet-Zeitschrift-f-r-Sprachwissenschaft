\NeedsTeXFormat{LaTeX2e}[2020/10/01]
\ProvidesClass{zsarticle}[2026/09/18 v4.2 Journal class for Zeitschrift fuer Sprachwissenschaft]

% ====================================================================
% zsarticle.cls --- article class for Zeitschrift fuer Sprachwissenschaft
% Authors: Miriam Butt, Sebastian Nordhoff, Stefan Müller, Anna Kocher, Oliver Schallert
% Bug reports provided by Daniel Gutzmann and Katharina Turgay
% ====================================================================
%
% Design principles:
%   * KOMA-Script scrartcl as the base class
%   * LuaLaTeX is the preferred engine; XeLaTeX is accepted with a warning
%   * biblatex + biber only
%   * preserve the established ZS geometry, fonts, colours, and general
%     front-matter layout while removing obsolete legacy code
%   * use KOMA interfaces wherever possible
%   * support a separate submission mode for anonymous review copies
%
% Changes in v4.2:
%   * \and is no longer resolved with \xdef.  Author lists containing
%     \thanks, \footnote, \\, accents or user macros no longer break the
%     running head, the copyright line, or the PDF metadata.
%   * the author-name branch of the title block is reachable again
%   * \glt is left to cgloss4e instead of being overwritten
%   * \cfoot* so that float/plain pages keep their folio
%   * \footheight now fits inside \footskip
%   * biblatex compatibility macros are \providecommand-ed after biblatex
%     has finished setting itself up
%   * \footnotesize redefined in full, including display and list skips
%   * published + submission are now mutually exclusive
%   * \maketitle accepts KOMA's optional page-number argument again
%

% ====================================================================
% 1. Engine handling and class options
% ====================================================================

\RequirePackage{iftex}
\ifluatex
  % Preferred engine.
\else\ifxetex
  \ClassWarningNoLine{zsarticle}{%
    XeLaTeX support is provided only as a fallback.\MessageBreak
    LuaLaTeX remains the preferred engine for this class%
  }
\else
  \ClassError{zsarticle}{This class requires LuaLaTeX or XeLaTeX}{%
    Run the document with lualatex. XeLaTeX is accepted as a fallback.}
\fi\fi

\newif\ifzsarticle@final
\newif\ifzsarticle@submission
\zsarticle@finalfalse
\zsarticle@submissionfalse

\DeclareOption{published}{\zsarticle@finaltrue}
\DeclareOption{submission}{\zsarticle@submissiontrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{scrartcl}}
\ProcessOptions\relax

\ifzsarticle@final
  \ifzsarticle@submission
    \ClassError{zsarticle}{Options `published' and `submission' conflict}{%
      Choose exactly one of them. `submission' produces an anonymous
      review copy; `published' produces the final typeset version.}
  \fi
\fi

\LoadClass[
  11pt,
  twoside,
  a4paper,
  headings=normal,
  parskip=half,
  numbers=noendperiod
]{scrartcl}

% ====================================================================
% 2. Required packages
% ====================================================================

\RequirePackage{etoolbox}
\RequirePackage{xspace}
\RequirePackage{xcolor}
\RequirePackage{graphicx}
\RequirePackage{float}
\RequirePackage{subcaption}
\RequirePackage{tikz}
\RequirePackage{enumitem}
\RequirePackage[para,flushleft]{threeparttable}
\RequirePackage[leqno,tbtags]{amsmath}
\RequirePackage{amssymb}
\RequirePackage{array}
\RequirePackage{booktabs}
\RequirePackage{fontspec}
\RequirePackage{unicode-math}
\RequirePackage{geometry}
\RequirePackage{scrlayer-scrpage}
\IfFileExists{microtype.sty}{\RequirePackage{microtype}}{}
\RequirePackage{caption}
% csquotes silences a biblatex warning and gives authors \enquote{...}
\IfFileExists{csquotes.sty}{\RequirePackage{csquotes}}{}
\RequirePackage{hyperref}
\RequirePackage{doi}
\RequirePackage[backend=biber,style=langsci-unified]{biblatex}
\RequirePackage{linguex}
% NOTE: linguex and cgloss4e both define \gll/\glt; cgloss4e is loaded
% second and therefore wins.  If glossing misbehaves, drop one of them
% rather than patching their internals.
\RequirePackage{cgloss4e}

% ====================================================================
% 3. Fonts and typography
% ====================================================================

\defaultfontfeatures{Ligatures=TeX,Scale=MatchLowercase}
\setmainfont{Libertinus Serif}
\setsansfont{Libertinus Sans}
\setmonofont{Libertinus Mono}
\IfFontExistsTF{TeX Gyre Pagella Math}{%
  \setmathfont[math-style=ISO,bold-style=ISO]{TeX Gyre Pagella Math}%
}{%
  \ClassWarningNoLine{zsarticle}{TeX Gyre Pagella Math not found; falling back to Latin Modern Math}%
  \setmathfont{Latin Modern Math}%
}

\urlstyle{rm}
\raggedbottom
\setlength{\parindent}{0pt}

% Line spacing: Word template uses 276/240 ≈ 1.15
% NOTE: this is global, so the explicit \fontsize{10}{12} settings in the
% front matter are effectively 10/12.96.
\linespread{1.08}\selectfont  % linespread × 1.065 (Libertinus) ≈ 1.15

% ====================================================================
% 4. Page layout
% ====================================================================

% footskip must be at least \footheight, otherwise scrlayer-scrpage
% warns and the (tall) first-page footer runs into the text block.
\geometry{
  paper=a4paper,
  top=4.0cm,
  bottom=5.0cm,
  inner=3cm,
  outer=3cm,
  headheight=1.9cm,
  headsep=0.5cm,
  footskip=2.4cm,
  includehead
}

\setlength{\footheight}{58pt}  % < 2.4cm (≈68pt)

\AtBeginDocument{%
  \@ifundefined{mathindent}{}{\setlength{\mathindent}{0.5in}}%
}

% ====================================================================
% 5. Colours and hyperlinks
% ====================================================================

% ZS brand blue from Word template: #1E4193
\definecolor{zscolor}{HTML}{1E4193}
\definecolor{zslinkcolor}{HTML}{1E4193}
% Lighter ZS blue (from logo decorative lines) for abstract rules
\definecolor{zslightblue}{HTML}{A1C1E7}

\hypersetup{
  colorlinks=true,
  breaklinks=true,
  linkcolor=zslinkcolor,
  urlcolor=zslinkcolor,
  citecolor=zslinkcolor,
  filecolor=zslinkcolor,
  plainpages=false,
  pdfstartview=FitH
}

% ====================================================================
% 6. PDF metadata and journal metadata
% ====================================================================

\newcommand*\zsarticle@pdfauthor{}
\newcommand*\zsarticle@pdftitle{}
\newcommand*\zsarticle@pdfkeywords{}

\providecommand*{\pdfauthor}{}
\providecommand*{\pdftitle}{}
\providecommand*{\pdfkeywords}{}
\renewcommand*{\pdfauthor}[1]{\gdef\zsarticle@pdfauthor{#1}}
\renewcommand*{\pdftitle}[1]{\gdef\zsarticle@pdftitle{#1}}
\renewcommand*{\pdfkeywords}[1]{\gdef\zsarticle@pdfkeywords{#1}}

\newcommand*\zsarticle@volume{XX}
\newcommand*\zsarticle@issue{Y}
\newcommand*\zsarticle@article{Z}
\newcommand*\zsarticle@year{\the\year}
\newcommand*\zsarticle@doi{10.1515/zfs-YYYY-200Z}
\newcommand*\zsarticle@received{month year}
\newcommand*\zsarticle@accepted{month year}
\newcommand*\zsarticle@published{month year}
\newcommand*\zsarticle@citation{Author. Year. Title: Subtitle. \textit{Zeitschrift für Sprachwissenschaft} Vol(Nr).}
\newcommand*\zsarticle@keywords{}
\newcommand*\zsarticle@correspondence{}
\newcommand*\zsarticle@funding{}
\newcommand*\zsarticle@lastpage{}

\newcommand{\zsvolume}[1]{\gdef\zsarticle@volume{#1}}
\newcommand{\zsissue}[1]{\gdef\zsarticle@issue{#1}}
\newcommand{\zsarticle}[1]{\gdef\zsarticle@article{#1}}
\newcommand{\zsyear}[1]{\gdef\zsarticle@year{#1}}
\newcommand{\zsdoi}[1]{\gdef\zsarticle@doi{#1}}
\newcommand{\zsreceived}[1]{\gdef\zsarticle@received{#1}}
\newcommand{\zsaccepted}[1]{\gdef\zsarticle@accepted{#1}}
\newcommand{\zspublished}[1]{\gdef\zsarticle@published{#1}}
\newcommand{\zscitation}[1]{\gdef\zsarticle@citation{#1}}
\newcommand{\zslastpage}[1]{\gdef\zsarticle@lastpage{#1}}
\newcommand{\keywords}[1]{\gdef\zsarticle@keywords{#1}}
\newcommand{\correspondence}[1]{\gdef\zsarticle@correspondence{#1}}

% ====================================================================
% 7. Title, author, affiliations, and running-head data
% ====================================================================

\newcommand*\zsarticle@shorttitle{}
\newcommand*\zsarticle@shortauthor{}
\newcommand*\zsarticle@affiliations{}

\NewCommandCopy\zsarticle@origtitle\title
\RenewDocumentCommand{\title}{O{} m}{%
  \zsarticle@origtitle{#2}%
  \gdef\zsarticle@shorttitle{#1}%
}

% Store author text directly (avoid KOMA-Script tabular \and handling)
\newcommand*\zsarticle@authortext{}
\NewCommandCopy\zsarticle@origauthor\author
\RenewDocumentCommand{\author}{O{} m}{%
  \zsarticle@origauthor{#2}%
  \gdef\zsarticle@shortauthor{#1}%
  \gdef\zsarticle@authortext{#2}%
}

\newcommand{\shorttitle}[1]{\gdef\zsarticle@shorttitle{#1}}
\newcommand{\shortauthor}[1]{\gdef\zsarticle@shortauthor{#1}}
\newcommand{\affiliation}[1]{%
  \gappto\zsarticle@affiliations{#1\par}%
}
\newcommand{\zsauthor}[1]{#1}

% --------------------------------------------------------------------
% 7a. Author-list formatting
%
% The author argument is *typeset*, never \edef-ed.  Expanding it with
% \xdef breaks on \thanks, \footnote, \\, \textsuperscript, accents and
% any user-defined macro, and drags footnote bodies into running heads.
%
% \zsarticle@authorlist{<separator>}
%     typeset the author list with <separator> between entries
% \zsarticle@runauthor
%     the same, comma-separated, with footnote material removed --
%     suitable for running heads and the copyright line
%
% To change the running-head separator, edit \def\and{, } below.
% --------------------------------------------------------------------

\newcommand*{\zsarticle@stripnotes}{%
  \def\thanks##1{}%
  \def\footnote##1{}%
  \def\footnotemark{}%
  \def\footnotetext##1{}%
  \def\\{\space}%
}

\newcommand*{\zsarticle@authorlist}[1]{%
  \begingroup
    \def\and{#1}%
    \zsarticle@authortext
  \endgroup
}

\newcommand*{\zsarticle@runauthor}{%
  \begingroup
    \zsarticle@stripnotes
    \zsarticle@authorlist{, }%
  \endgroup
}

% Keep footnote machinery out of the PDF string as well.
\pdfstringdefDisableCommands{%
  \def\and{, }%
  \def\thanks#1{}%
  \def\footnote#1{}%
  \def\footnotemark{}%
  \def\\{ }%
}

\AtBeginDocument{%
  \ifdefempty{\zsarticle@shorttitle}{\gdef\zsarticle@shorttitle{\@title}}{}%
  \ifdefempty{\zsarticle@shortauthor}{%
    \ifzsarticle@submission
      \gdef\zsarticle@shortauthor{Anonymous}%
    \else
      % \gdef, not \xdef: resolved at shipout, when typesetting is legal.
      \gdef\zsarticle@shortauthor{\zsarticle@runauthor}%
    \fi
  }{}%
}

\AtBeginDocument{%
  \ifzsarticle@submission
    \hypersetup{pdfauthor={},pdftitle={\@title},pdfkeywords={}}%
  \else
    \ifdefempty{\zsarticle@pdfauthor}{%
      \gdef\zsarticle@pdfauthor{\zsarticle@authortext}%
    }{}%
    \ifdefempty{\zsarticle@pdftitle}{\gdef\zsarticle@pdftitle{\@title}}{}%
    \ifdefempty{\zsarticle@pdfkeywords}{%
      \gdef\zsarticle@pdfkeywords{\zsarticle@keywords}%
    }{}%
    \hypersetup{%
      pdfauthor={\zsarticle@pdfauthor},%
      pdftitle={\zsarticle@pdftitle},%
      pdfkeywords={\zsarticle@pdfkeywords}%
    }%
  \fi
}

% ====================================================================
% 8. First-page material and front matter
% ====================================================================

\newcommand{\zsarticle@draftlicense}{%
  \fontsize{10}{12}\selectfont
  \textcolor{zscolor}{\textbf{Cite as:} \zsarticle@citation\space https://doi.org/\zsarticle@doi}\par\smallskip
  \textcolor{zscolor}{\textbf{Received:} \zsarticle@received; \textbf{accepted:} \zsarticle@accepted; \textbf{published:} \zsarticle@published}\par\smallskip
  \textcolor{zscolor}{\textbf{Published by:} publikon / dgfs (Linguistic Society of Germany) under a Creative Commons 4.0 BY license}%
}

\newcommand{\zsarticle@finallicense}{%
  \fontsize{10}{12}\selectfont This is an open-access article distributed under the terms of a Creative Commons License (\url{https://creativecommons.org/licenses/by/4.0/}).%
}

\newif\ifzsarticle@logo
\zsarticle@logotrue
\newcommand{\zslogo}{\zsarticle@logotrue}
\newcommand{\nozslogo}{\zsarticle@logofalse}

\newcommand{\zsarticle@logobox}{%
  \ifzsarticle@logo
    \IfFileExists{zs-logo.pdf}{%
      \href{https://ojs.ub.uni-konstanz.de/zs/}{\includegraphics[width=\linewidth]{zs-logo}}%
    }{}%
  \fi
}

\newcommand{\zsarticle@firsthead}{%
  \begin{minipage}[c]{0.48\textwidth}
    \zsarticle@logobox
  \end{minipage}%
  \hfill
  \begin{minipage}[c]{0.48\textwidth}
    \raggedleft\color{zscolor}\fontsize{10}{12}\selectfont
    Volume \zsarticle@volume, Issue \zsarticle@issue, Article \zsarticle@article\par
    \smallskip
    \url{https://doi.org/\zsarticle@doi}%
  \end{minipage}%
}

\newcommand{\zsarticle@firstfoot}{%
  \begin{minipage}[t]{\textwidth}
    \ifzsarticle@submission
      \fontsize{10}{12}\selectfont\textcolor{zscolor}{Anonymous submission version}%
    \else\ifzsarticle@final
      \fontsize{10}{12}\selectfont\copyright\ \zsarticle@year\ \zsarticle@shortauthor\par
      \zsarticle@finallicense
    \else
      \zsarticle@draftlicense
    \fi\fi
  \end{minipage}%
}

% A newly declared pair of page styles is empty already; no \clearpair...
% is needed inside (and calling it here would clear more than intended).
\newpairofpagestyles{zsarticlefirstpage}{%
  \ihead{}
  \chead{}
  \ohead{\zsarticle@firsthead}
  \ifoot{}
  \cfoot{}
  \ofoot{\zsarticle@firstfoot}
}

% Author block: each affiliation on its own line, 10pt bold
% (matching Word "Author" style).  If \affiliation is used, the
% affiliation lines are printed *in addition to* the author names, so
% that \author is never silently dropped from the title page.
\newcommand*{\zsarticle@printauthorblock}{%
  \ifzsarticle@submission
    {\fontsize{10}{12}\selectfont\bfseries Anonymous author(s)\par}%
  \else
    {\fontsize{10}{12}\selectfont\bfseries
     \ifdefempty{\zsarticle@authortext}{}{%
       \zsarticle@authorlist{, }\par
     }%
     \ifdefempty{\zsarticle@affiliations}{}{%
       \zsarticle@affiliations
     }%
    }%
  \fi
}

% Title: Libertinus Sans 19pt bold, zscolor
% Subtitle: Libertinus Sans 15pt bold, zscolor
% The optional argument is KOMA's page number for the title page.
\RenewDocumentCommand{\maketitle}{O{}}{%
  \IfNoValueTF{#1}{}{%
    \ifstrempty{#1}{}{\setcounter{page}{#1}}%
  }%
  \thispagestyle{zsarticlefirstpage}%
  \begingroup
    \renewcommand{\thefootnote}{\fnsymbol{footnote}}%
    \par\vspace*{24pt}%
    \zsarticle@printauthorblock
    \vspace{18pt}%
    {\sffamily\fontsize{19}{23}\selectfont\bfseries\color{zscolor} \@title\par}%
    \ifdefempty{\@subtitle}{}{%
      {\sffamily\fontsize{15}{19}\selectfont\bfseries\color{zscolor} \@subtitle\par}%
    }%
    \vspace{18pt}%
    \@thanks
  \endgroup
  \setcounter{footnote}{0}%
  \global\let\thanks\relax
  \global\let\maketitle\relax
}

% Abstract: 10pt, with bold "Abstract:" label and "Keywords:" label
\newcommand{\frontmatterspacing}[1]{%
  \fontsize{10}{13}\selectfont
  \topsep 24\p@ \@plus4\p@ \@minus6\p@
  \setlength{\listparindent}{0em}
  \setlength{\itemindent}{0em}
  \setlength{\leftmargin}{#1}
  \setlength{\rightmargin}{\leftmargin}
  \setlength{\parskip}{0em}
}

\newenvironment{mshistory}
  {\list{}{\frontmatterspacing{0em}}\item\relax}
  {\endlist}

% Abstract with blue rules above and below, page break after
\renewenvironment{abstract}
  {%
    \par\addvspace{24pt}%
    {\color{zslightblue}\hrule height 1.5pt}%
    \list{}{\frontmatterspacing{0em}}\item\relax\textbf{\abstractname:} }
  {%
    \ifdefempty{\zsarticle@keywords}{}{%
      \par\smallskip\textbf{Keywords:} \zsarticle@keywords%
    }%
    \endlist
    \vspace{-2pt}%
    {\color{zslightblue}\hrule height 1.5pt}%
    \newpage
  }

% Acknowledgements and Funding: 10pt, bold label
\NewDocumentEnvironment{acknowledgements}{+b}{%
\ifzsarticle@submission\else
\par\addvspace{24pt}%
{\fontsize{10}{13}\selectfont\noindent
\textbf{Acknowledgements:} #1\par}%
\fi}{}

\NewDocumentEnvironment{funding}{+b}
  {%
    \ifzsarticle@submission
    \else
      \par\addvspace{16pt}%
      {\fontsize{10}{13}\selectfont
       \noindent\textbf{Funding:} #1\par}%
    \fi
  }
  {}

\newenvironment{abbreviations}
  {\section*{Abbreviations}\ignorespaces}
  {\par}

% ====================================================================
% 9. Running heads and page style
% ====================================================================

% Running heads: author name always on left, short title always on right
\clearpairofpagestyles
\lehead{\color{zscolor}\fontsize{9}{11}\selectfont \zsarticle@shortauthor}
\lohead{\color{zscolor}\fontsize{9}{11}\selectfont \zsarticle@shortauthor}
\rehead{\color{zscolor}\fontsize{9}{11}\selectfont \zsarticle@shorttitle}
\rohead{\color{zscolor}\fontsize{9}{11}\selectfont \zsarticle@shorttitle}
% starred: also applies to `plain' pages (float pages keep their folio)
\cfoot*{\color{zscolor}\thepage}
\renewcommand*{\headfont}{\normalfont}
\renewcommand*{\footfont}{\normalfont}
\pagestyle{scrheadings}

% ====================================================================
% 10. Sectioning and cross-reference helpers
% ====================================================================

% Heading 1: Libertinus Sans 14pt bold, 24pt before
\RedeclareSectionCommand[
  beforeskip=-24pt plus -4pt minus -2pt,
  afterskip=8pt plus 2pt,
  font=\sffamily\fontsize{14}{17}\selectfont\bfseries
]{section}

% Heading 2: Libertinus Sans 13pt bold, 18pt before
\RedeclareSectionCommand[
  beforeskip=-18pt plus -4pt minus -2pt,
  afterskip=6pt plus 2pt,
  font=\sffamily\fontsize{13}{16}\selectfont\bfseries
]{subsection}

% Heading 3: Libertinus Sans 12pt bold, 12pt before
\RedeclareSectionCommand[
  beforeskip=-12pt plus -2pt minus -1pt,
  afterskip=4pt plus 1pt,
  font=\sffamily\fontsize{12}{15}\selectfont\bfseries
]{subsubsection}

% Heading 4: Libertinus Sans 11pt bold, unnumbered, 10pt before
\setcounter{secnumdepth}{3}  % number only down to subsubsection
\RedeclareSectionCommand[
  beforeskip=-10pt plus -2pt minus -1pt,
  afterskip=4pt plus 1pt,
  font=\sffamily\fontsize{11}{14}\selectfont\bfseries
]{paragraph}

\renewcommand*{\sectionformat}{\thesection\enskip}
\renewcommand*{\subsectionformat}{\thesubsection\enskip}
\renewcommand*{\subsubsectionformat}{\thesubsubsection\enskip}

% Block quotes: 10pt, indented left and right ~7mm
\newenvironment{zsquote}
  {\par\addvspace{4pt}%
   \list{}{\fontsize{10}{13}\selectfont
           \setlength{\leftmargin}{7.09mm}%
           \setlength{\rightmargin}{7.09mm}%
           \setlength{\listparindent}{0pt}%
           \setlength{\parsep}{0pt}%
           \setlength{\itemsep}{0pt}%
   }\item\relax}
  {\endlist\addvspace{4pt}}

\newcommand{\Secref}[1]{Section~\ref{#1}}
\newcommand{\Subsecref}[1]{Section~\ref{#1}}
\newcommand{\Appref}[1]{Appendix~\ref{#1}}
\newcommand{\Figref}[1]{Figure~\ref{#1}}
\newcommand{\Tabref}[1]{Table~\ref{#1}}
\newcommand{\Footref}[1]{Footnote~\ref{#1}}

% ====================================================================
% 11. Lists, footnotes, tables, figures, and captions
% ====================================================================

% Lists: en-dash markers, matching Word indent (left ~7.14mm, hanging ~3.57mm)
\setlist[itemize]{
  label=\textendash,
  leftmargin=7.14mm,
  labelwidth=3.57mm,
  labelsep=1mm,
  itemsep=0pt,
  topsep=4pt,
  parsep=4pt,
  partopsep=0pt
}
\setlist[enumerate]{
  leftmargin=7.14mm,
  itemsep=0pt,
  topsep=4pt,
  parsep=4pt,
  partopsep=0pt
}

% ====================================================================
% 11a. Linguex configuration
% ====================================================================

% Adjust linguex spacing and indentation to match ZS style
\AtBeginDocument{%
  \setlength{\Exindent}{0pt}%
  \setlength{\Exlabelsep}{0.5em}%
  \setlength{\SubExleftmargin}{1.5em}%
  \setlength{\SubSubExleftmargin}{2em}%
  % Remove dash between example number and subexample letter: (4a) not (4-a)
  \renewcommand{\firstrefdash}{}%
}

% Gloss formatting: italicize the first line of glosses (object language)
\let\eachwordone=\itshape
% Second line (glosses) and third line (translation) in regular font
\let\eachwordtwo=\relax
\let\eachwordthree=\relax

% NOTE: \glt is cgloss4e's *terminator* for the aligned gloss block, not
% a spacing hook.  Redefining it (as earlier versions of this class did)
% destroys the translation line.  Adjust \Extopsep / \Exlabelsep or the
% surrounding \addvspace instead if the gap needs tightening.

% ====================================================================

% Footnotes: 9pt, line spacing ~1.04
\renewcommand{\@makefntext}[1]{%
  \parindent=0.25in
  \noindent\textsuperscript{\@thefnmark}\ %
  {\footnotesize #1}%
}

% Redefined in full: a bare \fontsize would leave display-math and list
% skips at whatever the previously selected size had set them to.
\renewcommand{\footnotesize}{%
  \fontsize{9}{9.4}\selectfont
  \abovedisplayskip 6\p@ \@plus2\p@ \@minus2\p@
  \abovedisplayshortskip \z@ \@plus\p@
  \belowdisplayshortskip 3\p@ \@plus\p@ \@minus2\p@
  \def\@listi{\leftmargin\leftmargini
              \topsep 3\p@ \@plus\p@ \@minus\p@
              \parsep 2\p@ \@plus\p@ \@minus\p@
              \itemsep \parsep}%
  \belowdisplayskip \abovedisplayskip
}

% Captions: Libertinus Sans, 10pt, bold label, flush left, colon separator
\captionsetup{
  justification=raggedright,
  singlelinecheck=false,
  format=plain,
  labelsep=colon,
  labelfont=bf,
  font={sf,small}
}
\captionsetup[table]{position=above}
\captionsetup[figure]{position=bottom}
\setlength{\abovecaptionskip}{5pt}
\setlength{\belowcaptionskip}{5pt}

% Sans-serif defaults inside tables and figures
\AtBeginEnvironment{table}{\sffamily\normalsize}
\AtBeginEnvironment{figure}{\sffamily}
\AtBeginEnvironment{tabular}{\sffamily\normalsize\renewcommand{\arraystretch}{1}}
\AtBeginEnvironment{tabular*}{\sffamily\normalsize\renewcommand{\arraystretch}{1}}
\AtBeginEnvironment{threeparttable}{\sffamily\normalsize}

% Bold table headers
\newcommand{\tablehead}[1]{\textbf{#1}}

% ====================================================================
% 12. Bibliography and citation compatibility helpers
% ====================================================================

% Reference entries: 10pt, hanging indent ~4.54mm
\renewcommand*{\bibfont}{\fontsize{10}{13}\selectfont}
\setlength{\bibitemsep}{3pt}
\setlength{\bibhang}{4.54mm}

% Minimal migration helpers for older manuscripts.
% \providecommand inside \AtBeginDocument: biblatex and the citation
% style have finished loading by then, so we never clash with a
% definition they provide themselves.
\AtBeginDocument{%
  \providecommand{\citealt}[1]{\cite{#1}}%
  \providecommand{\pgposscitet}[2]{\citeauthor{#1}\textquoteright s (\citeyear{#1}:~#2)}%
  \providecommand{\secposscitet}[2]{\citeauthor{#1}\textquoteright s (\citeyear{#1}:~\S#2)}%
  \providecommand{\pgcitealt}[2]{\cite[#2]{#1}}%
  \providecommand{\seccitealt}[2]{\textcite{#1}:~\S#2}%
  \providecommand{\pgcitep}[2]{\parencite[#2]{#1}}%
  \providecommand{\seccitep}[2]{(\parencite{#1}:~\S#2)}%
  \providecommand{\pgcitet}[2]{\textcite[#2]{#1}}%
  \providecommand{\seccitet}[2]{\textcite{#1}:~\S#2}%
  \providecommand{\BIBand}{\&}%
}

% ====================================================================
% 13. Gentle semantic formatting helpers
% ====================================================================

\newcommand{\term}[1]{\textit{#1}}
\newcommand{\objlang}[1]{\textit{#1}}
\newcommand{\focus}[1]{\textsc{#1}}
\newcommand{\translation}[1]{\textquoteleft #1\textquoteright}

% ====================================================================
% 14. Back matter and utility macros
% ====================================================================

\newenvironment{addresses}
  {%
    \par\addvspace{3.25ex}%
    \noindent\small
    \newenvironment{address}
      {\begin{minipage}[t]{19pc}\raggedright}
      {\end{minipage}\hspace{.15pc plus1pc}}%
    \ignorespaces
  }
  {\par}

\def\co{\colon\thinspace}

% Spaced en dash for parenthetical dashes (ZS convention)
\DeclareRobustCommand\dash{\unskip~\textendash\space\ignorespaces}

\pdfstringdefDisableCommands{\renewcommand{\dash}{ - }}

\newcommand{\email}[1]{\href{mailto:#1}{#1}}
\providecommand{\sv}[1]{\ensuremath{\lBrack \text{#1} \rBrack}}
\DeclareRobustCommand*{\http}[1]{\url{http://#1}}

% ====================================================================
% End of file
% ====================================================================