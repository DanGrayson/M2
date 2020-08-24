-*- coding: utf-8 -*-
-----------------------------------------------------------------------------
-- html output
-----------------------------------------------------------------------------

KaTeX := () -> (
    katexPath := locateCorePackageFileRelative("Style",
	layout -> replace("PKG", "Style", layout#"package") | "katex", installPrefix, htmlDirectory);
    katexTemplate := ///
    <link rel="stylesheet" href="%PATH%/katex.min.css" />
    <script defer src="%PATH%/katex.min.js"></script>
    <script defer src="%PATH%/contrib/auto-render.min.js"
        onload="renderMathInElement(document.body);"></script>
    <script>
      var macros = {
          "\\break": "\\\\",
          "\\R": "\\mathbb{R}",
          "\\C": "\\mathbb{C}",
          "\\ZZ": "\\mathbb{Z}",
          "\\NN": "\\mathbb{N}",
          "\\QQ": "\\mathbb{Q}",
          "\\RR": "\\mathbb{R}",
          "\\CC": "\\mathbb{C}",
          "\\PP": "\\mathbb{P}"
      }, delimiters = [
          { left: "$$",  right: "$$",  display: true},
          { left: "\\[", right: "\\]", display: true},
          { left: "$",   right: "$",   display: false},
          { left: "\\(", right: "\\)", display: false}
      ];
      document.addEventListener("DOMContentLoaded", function() {
        renderMathInElement(document.body, { delimiters: delimiters, macros: macros });
      });
    </script>
    <style>.katex { font-size: 1em; }</style>
    <link href="%PATH%/contrib/copy-tex.min.css" rel="stylesheet" type="text/css" />
    <script src="%PATH%/contrib/copy-tex.min.js"></script>
    <script src="%PATH%/contrib/render-a11y-string.min.js"></script>///;
    LITERAL replace("%PATH%", katexPath, katexTemplate))

-- The default stylesheet for documentation
defaultStylesheet := () -> LINK {
    "rel" => "stylesheet", "type" => "text/css",
    "href" => locateCorePackageFileRelative("Style",
	layout -> replace("PKG", "Style", layout#"package") | "doc.css", installPrefix, htmlDirectory)}

-- Also set the character encoding with a meta http-equiv statement. (Sometimes XHTML
-- is parsed as HTML, and then the HTTP header or a meta tag is used to determine the
-- character encoding.  Locally-stored documentation does not have an HTTP header.)
defaultCharset := () -> META { "http-equiv" => "Content-Type", "content" => "text/html; charset=utf-8" }

defaultHEAD = title -> HEAD splice { TITLE title, defaultCharset(), defaultStylesheet(), KaTeX() }

-----------------------------------------------------------------------------
-- Local utilities
-----------------------------------------------------------------------------

-- TODO: urlEncode
htmlLiteral = s -> if s === null or not match("<|&|]]>|\42", s) then s else (
     s = replace("&", "&amp;", s); -- this one must come first
     s = replace("<", "&lt;", s);
     s = replace("]]>", "]]&gt;", s);
     s = replace("\42", "&quot;", s);  -- note: \42 is "
     s )

-- tracking indentations
indentLevel := -1
pushIndentLevel =  n     -> (indentLevel = indentLevel + n; n)
popIndentLevel  = (n, s) -> (indentLevel = indentLevel - n; s)

-- whether fn exists on the path
-- TODO: check executable
runnable := fn -> (
    if fn == "" then return false;
    if isAbsolutePath fn then fileExists fn
    else 0 < # select(1, apply(separate(":", getenv "PATH"), p -> p|"/"|fn), fileExists))

-- preferred web browser
-- TODO: cache this value
browser := () -> (
    if runnable getenv "WWWBROWSER" then getenv "WWWBROWSER" -- compatibility
    else if version#"operating system" === "Darwin" and runnable "open" then "open" -- Apple varieties
    else if runnable "xdg-open" then "xdg-open" -- most Linux distributions
    else if runnable "firefox" then "firefox" -- backup
    else error "neither open nor xdg-open is found and WWWBROWSER is not set")

-----------------------------------------------------------------------------
-- Setup default rendering
-----------------------------------------------------------------------------

-- This method applies to all types that inherit from Hypertext
-- Most MarkUpTypes automatically work recursively
html Hypertext := x -> (
    T := class x;
    qname := T.qname;
    attr := "";
    cont := if T.?Options then (
	(op, ct) := try override(options T, toSequence x) else error("markup type ", toString T, ": ",
	    "unrecognized option name(s): ", toString select(toList x, c -> instance(c, Option)));
	scanPairs(op, (key, val) -> if val =!= null then attr = " " | key | "=" | format val | attr);
	sequence ct) else x;
    pushIndentLevel 1;
    (head, prefix, suffix, tail) := (
	if instance(x, HypertextContainer) then (concatenate(indentLevel:"  "), newline, concatenate(indentLevel:"  "), newline) else
	if instance(x, HypertextParagraph) then (concatenate(indentLevel:"  "), "", "", newline) else ("","","",""));
    popIndentLevel(1, if #cont == 0
	then concatenate(head, "<", qname, attr, "/>", tail)
	else concatenate(head, "<", qname, attr, ">", prefix,
	    apply(cont, html), suffix, "</", qname, ">", tail)))

-----------------------------------------------------------------------------
-- Exceptional (html, MarkUpType) methods
-----------------------------------------------------------------------------

-- TOH  -- see format.m2

html LITERAL := x -> concatenate x
html String  := x -> htmlLiteral x
html TEX     := x -> concatenate apply(x, s -> (
	if not instance(s, String) then return html s;
	-- parsing matching braces wrapped with \url{...}
	re   := "(\\\\(url)\\{((?:[^}{]+|(?1))*+)\\})";
	form := "DELIMITER, \\U\\2\\E{DELIMITER\\3DELIMITER}, DELIMITER";
	while match(re, s) do (
	    tag := toUpper substring(lastMatch#2, s);
	    if not match("URL", tag) then error("unknown TeX sequence: ", tag);
	    if debugLevel > 1 then printerr("parsing ", tag, " in TEX");
	    s = replace(re, form, s));
	-- parsing matching braces wrapped with {\xx ...}
	re   = "(\\{\\\\(bf|tt|em|cal|it) *((?:[^}{]+|(?1))*+)\\})";
	form = "DELIMITER, \\U\\2\\E{DELIMITER\\3DELIMITER}, DELIMITER";
	while match(re, s) do (
	    tag = toUpper substring(lastMatch#2, s);
	    if not match("BF|TT|EM|CAL|IT", tag) then error("unknown TeX sequence: ", tag);
	    if debugLevel > 1 then printerr("parsing ", tag, " in TEX");
	    s = replace(re, form, s));
	s = format s;
	-- replacing a few mis-matched typenames
	s = replace("DELIMITER, BF{", "\", BOLD{", s);
	s = replace("DELIMITER, IT{", "\", ITALIC{", s);
	s = replace("DELIMITER, CAL{", "\", ITALIC{", s); -- TODO: deprecate this
	s = replace("DELIMITER, URL{", "\", HREF{", s);
	s = replace("DELIMITER", "\"", s);
	-- evaluate Hypertext types
	s = evaluateWithPackage(getpkg "Text", s, value);
	if instance(s, String) then html s
	else concatenate apply(s, html)))

html HTML := x -> demark(newline, {
    	///<?xml version="1.0" encoding="utf-8" ?>///,
    	///<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1 plus MathML 2.0 plus SVG 1.1//EN" "http://www.w3.org/2002/04/xhtml-math-svg/xhtml-math-svg.dtd">///,
    	///<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">///,
    	popIndentLevel(pushIndentLevel 1, apply(x, html)),
	///</html>///})

treatImgSrc := x -> apply(x, y -> if class y === Option and y#0 === "src" then "src" => htmlLiteral toURL y#1 else y)
html IMG := (lookup(html, IMG)) @@ treatImgSrc

splitLines := x -> apply(x, y -> if class y === String then demark(newline, lines y) else y) -- effectively, \r\n -> \n and removes last [\r]\n
html PRE := (lookup(html, PRE)) @@ splitLines

html CDATA   := x -> concatenate("<![CDATA[",x,"]]>")
html COMMENT := x -> concatenate("<!--",x,"-->")

html HREF := x -> (
     r := html last x;
     r = if match("^ +$", r) then #r : "&nbsp;&nbsp;" else r;
     concatenate("<a href=\"", htmlLiteral toURL first x, "\">", r, "</a>")
     )

html MENU := x -> html redoMENU x

-- TODO: reduce this
html TO   := x -> (
     tag := x#0;
     d := fetchRawDocumentation getPrimaryTag tag;
     r := htmlLiteral format tag;
     if match("^ +$",r) then r = #r : "&nbsp;&nbsp;";
     if d#?"undocumented" and d#"undocumented" === true then (
	  if signalDocumentationWarning tag then (
	       stderr << "--warning: tag cited also declared as undocumented: " << tag << endl;
	       warning();
	       );
	  concatenate( "<tt>", r, "</tt>", if x#?1 then x#1, " (missing documentation<!-- tag: ", toString tag.Key, " -->)")
	  )
     else if d === null					    -- isMissingDoc
     then (
	  warning("missing documentation: "|toString tag);
	  concatenate( "<tt>", r, "</tt>", if x#?1 then x#1, " (missing documentation<!-- tag: ", toString tag.Key, " -->)")
	  )
     else concatenate( "<a href=\"", toURL htmlFilename getPrimaryTag tag, "\" title=\"", htmlLiteral headline tag, "\">", r, "</a>", if x#?1 then x#1))

html TO2  := x -> (
     tag := x#0;
     headline tag;		   -- this is a kludge, just to generate error messages about missing links
     d := fetchRawDocumentation getPrimaryTag tag;
     if d#?"undocumented" and d#"undocumented" === true then (
	  if signalDocumentationWarning tag then (
	       stderr << "--warning: tag cited also declared as undocumented: " << tag << endl;
	       warning();
	       );
	  concatenate("<tt>", htmlLiteral x#1, "</tt> (missing documentation<!-- tag: ", format tag, " -->)")
	  )
     else if d === null					    -- isMissingDoc
     then (
	  warning("missing documentation: "|toString tag);
	  concatenate("<tt>", htmlLiteral x#1, "</tt> (missing documentation<!-- tag: ", format tag, " -->)"))
     else concatenate("<a href=\"", toURL htmlFilename getPrimaryTag tag, "\">", htmlLiteral x#1, "</a>"))

html VerticalList         := x -> html UL apply(x, html)
html NumberedVerticalList := x -> html OL apply(x, html)

-----------------------------------------------------------------------------
-- Viewing rendered html in a browser
-----------------------------------------------------------------------------

showHtml =
show Hypertext := x -> (
    fn := temporaryFileName() | ".html";
    addEndFunction( () -> if fileExists fn then removeFile fn );
    fn << html HTML { defaultHEAD "Macaulay2 Output", BODY {x}} << endl << close;
    show new URL from replace(" ", "%20", rootURI | realpath fn)) -- TODO: urlEncode might need to replace more characters
show URL := url -> (
    cmd := { browser(), url#0 }; -- TODO: silence browser messages, perhaps with "> /dev/null"
    if fork() == 0 then (
        setGroupID(0,0);
        try exec cmd;
        stderr << "exec failed: " << toExternalString cmd << endl;
        exit 1);
    sleep 1;) -- let the browser print errors before the next M2 prompt
