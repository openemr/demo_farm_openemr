<?php
/*
* Class for parsing BBCode
* @author	Paul Carter, http://cartpauj.icomnow.com
*Ui = 1 line
*Uis = Multiple Lines
*/
class cartpaujBBCParser {
	
	var $patterns = array
	(
		'/\[list\](.+)\[\/list\]/Uis',
		'/\[\*\](.+)\\n/Ui',
		'/\[b\](.+)\[\/b\]/Uis',
		'/\[i\](.+)\[\/i\]/Uis',
		'/\[u\](.+)\[\/u\]/Uis',
		'/\[s\](.+)\[\/s\]/Uis',
		'/\[url=(.+)\](.+)\[\/url\]/Ui',
		'/\[url](.+)\[\/url\]/Ui',
		'/\[email](.+)\[\/email\]/Ui',
		'/\[email=(.+)\](.+)\[\/email\]/Ui',
		'/\[img\](.+)\[\/img\]/Ui',
		'/\[img=(.+)\](.+)\[\/img\]/Ui',
		'/\[code\](.+)\[\/code\]/Uis',
		'/\[color=(\#[0-9a-f]{6}|[a-z]+)\](.+)\[\/color\]/Ui',
		'/\[color=(\#[0-9a-f]{6}|[a-z]+)\](.+)\[\/color\]/Uis',
		'/\[embed](.+)\[\/embed\]/Ui'
	);
	
	var $replacements = array
	(
		'<ul>\1</ul>',
		'<li>\1</li>',
		'<b>\1</b>',
		'<i>\1</i>',
		'<u>\1</u>',
		'<s>\1</s>',
		'<a href = "\1" target = "_blank">\2</a>',
		'<a href = "\1" target = "_blank">\1</a>',
		'<a href = "mailto:\1">\1</a>',
		'<a href = "mailto:\1">\2</a>',
		'<img src = "\1" alt = "Image" />',
		'<img src = "\1" alt = "\2" />',
		'<pre class = "code">\1</pre>',
		'<span style = "color: \1;">\2</span>',
		'<div style = "color: \1;">\2</div>',
		'\1'
	);
	
	function bbc2html($subject)
	{
		//$subject = nl2br($subject); //UCOMMENT THIS LINE TO REPLACE \n's with <br />'s
		
		$subject = preg_replace($this->patterns, $this->replacements, $subject);
		
		$findQ = array("[quote]", "[/quote]", "[QUOTE]", "[/QUOTE]");
		$replaceQ  = array("<blockquote>", "</blockquote>", "<blockquote>", "</blockquote>");
		$subjectTwo = str_replace($findQ, $replaceQ, $subject);
		
		return $subjectTwo;
	}
}
?>