#-------------------------------------------------------------------
#
#  Scraping HTML with the rvest package
#
#
#  This lab covers the basics of scraping text from online sources.
#-------------------------------------------------------------------


library(rvest)
library(stringr)
library(magrittr)

# Extract the tag names with html_tag(), text with html_text(), a single
# attribute with html_attr() or all attributes with html_attrs().
demo(package = "rvest")


#======================
#  1. Scraping HTML Text
#======================

#--------------------------
#  1.1 HTML Nodes
#--------------------------

# HTML elements are written with a start tag, an end tag, and with the content
# in between: <tagname>content</tagname>. The tags which typically contain the
# textual content we wish to scrape, and the tags we will leverage in the next
# two sections, include:
#   <h1>, <h2>,…,<h6> : Largest heading, second largest heading, etc. 
#   <p>               : Paragraph elements 
#   <ul>              : Unordered bulleted list 
#   <ol>              : Ordered list 
#   <li>              : Individual List item
#   <div>             : Division or section 
#   <table>           : Table 

# For example, text in paragraph form that you see online is wrapped with the
# HTML paragraph tag <p> as in:
#   <p> This paragraph represents 
#       a typical text paragraph 
#       in HTML form </p> 

# It is through these tags (also referred to as nodes) 
# that we can start to extract textual components of HTML webpages.


#----------------------------
#  1.2 Scraping HTML Nodes
#----------------------------

# rvest package was inspired by libraries such as beautiful soup 
# which has greatly simplified web scraping. 
# rvest makes use of of the pipe operator (%>%) developed through the magrittr package. 

# To extract text from a webpage of interest, we specify what HTML elements 
# we want to select by using html_nodes(). 

#--------------------------------------------------------------
#  1.2.1 Scraping HTML Nodes - headings with <h1>...<h6> nodes
#--------------------------------------------------------------
# For instance, if we want to scrape the primary heading 
# for the Web Scraping Wikipedia webpage 
# we simply identify the <h1> node as the node we want to select. 
# html_nodes() will identify all <h1> nodes on the webpage and return the HTML element. 
# In our example we see there is only one <h1> node on this webpage.

# pull the page once and store 
#   in case you want to parse multiple elements

url <- "https://en.wikipedia.org/wiki/Web_scraping"

# temp 1 - basic
wiki_scraping_page_1 <- read_html(url) ## pull the page once and store 

# temp 2 - using HTML session
pgsession <- html_session(url) ## create session               
wiki_scraping_page_2 <- ## pull the page once and store 
  pgsession %>% 
  jump_to(url) %>% 
  read_html()

# compare results
wiki_scraping_page_1
wiki_scraping_page_2

wiki_scraping_page <- wiki_scraping_page_1

# Identify all <h1> nodes on the webpage and return the HTML elements
wiki_scraping_page %>%
  html_nodes("h1")
#> {xml_nodeset (1)}
#> [1] <h1 id="firstHeading" class="firstHeading" lang="en">Web scraping</h1>


# To extract only the heading text for this <h1> node, 
# and not include all the HTML syntax we use html_text() 
# which returns the heading text we see at the top of the Web Scraping Wikipedia page.

# Extract only the heading text from <h1> nodes on the webpage
wiki_scraping_page %>%
  html_nodes("h1") %>%
  html_text()
#> [1] "Web scraping"

# If we want to identify all the second level headings on the webpage we follow
# the same process but instead select the <h2> nodes. In this example we see
# there are 10 second level headings on the Web Scraping Wikipedia page.

# Extract only the heading text from <h2> nodes on the webpage
wiki_scraping_page %>%
  html_nodes("h2") %>%
  html_text()
#>  [1] "Contents"                             
#>  [2] "Techniques[edit]"                     
#>  [3] "Legal issues[edit]"                   
#>  [4] "Notable tools[edit]"                  
#>  [5] "See also[edit]"                       
#>  [6] "Technical measures to stop bots[edit]"
#>  [7] "Articles[edit]"                       
#>  [8] "References[edit]"                     
#>  [9] "See also[edit]"                       
#> [10] "Navigation menu"


#--------------------------------------------------------------
#  1.2.2 Scraping HTML Nodes - paragraph with <p> nodes
#--------------------------------------------------------------
# Extracting the text on webpage which is in paragraph form.
# Coerce paragraph to a character string using html_text()

# We can follow the same process illustrated above but instead we’ll select all <p> nodes. 
# This selects the 32 paragraph elements from the web page; 
# which we can examine by subsetting the list p_nodes to see the first line 
# of each paragraph along with the HTML syntax. 
# Just as before, to extract the text from these nodes 
# and coerce them to a character string we simply apply html_text().

# Identify all <p> nodes on the webpage and return the HTML elements
p_nodes <- wiki_scraping_page %>% 
  html_nodes("p")

# Check No of the paragraph elements
length(p_nodes)
#> [1] 32

# Identify only six first paragraphs with <p> nodes on the webpage
p_nodes[1:6]
#> {xml_nodeset (6)}
#> [1] <p><b>Web scraping</b> (<b>web harvesting</b> or <b>web data extract ...
#> [2] <p>Web scraping is closely related to <a href="/wiki/Web_indexing" t ...
#> [3] <p/>
#> [4] <p/>
#> [5] <p>Web scraping is the process of automatically collecting informati ...
#> [6] <p>Web scraping may be against the <a href="/wiki/Terms_of_use" titl ...

# Extract only the paragraphs' text from <p> nodes on the webpage
p_text <- wiki_scraping_page %>%
  html_nodes("p") %>%
  html_text()

# Print text of the first paragraph as a character string
p_text[1]
#> [1] "Web scraping (web harvesting or web data extraction) is data scraping
# used for extracting data from websites.[1] Web scraping software may access the
# World Wide Web directly using the Hypertext Transfer Protocol, or through a web
# browser. While web scraping can be done manually by a software user, the term
# typically refers to automated processes implemented using a bot or web crawler.
# It is a form of copying, in which specific data is gathered and copied from the
# web, typically into a central local database or spreadsheet, for later
# retrieval or analysis."


#------------------------------------------------------------------
#  1.2.3 Scraping HTML Nodes - text in list format with <ul> nodes
#------------------------------------------------------------------
# Scraping the text in list format (contained in <ul> nodes)

# Allways check if you have captured all the text that you were hoping for. 
# Since we extracted text for all <p> nodes, we collected all identified paragraph text; 
# however, this does not capture the text in the bulleted lists 
# which can be displayed without <p> node. 

# To capture the text in lists, we can use the same steps as above 
# but we select specific nodes which represent HTML lists components. 

# We can approach extracting list text two ways.

#--------------------------------------------
#  Approach 1 - pull all list elements (<ul>)
#--------------------------------------------
# When scraping all <ul> text, the resulting data structure 
# will be a character string vector with each element 
# representing a single list consisting of all list items in that list.

ul_text <- wiki_scraping_page %>%
  html_nodes("ul") %>%
  html_text()

length(ul_text)
## [1] 26

ul_text[1]
#> [1] "1 Techniques\n1.1 Human copy-and-paste\n1.2 Text pattern matching\n1.3
## HTTP programming\n1.4 HTML parsing\n1.5 DOM parsing\n1.6 Vertical
## aggregation\n1.7 Semantic annotation recognizing\n1.8 Computer vision
## web-page analysis\n\n2 Software\n2.1 Example tools\n2.1.1 Javascript
## tools\n2.1.2 SaaS version\n2.1.3 Web crawling frameworks\n\n\n3 Legal
## issues\n3.1 United States\n3.2 Outside the United States\n\n4 Methods to
## prevent web scraping\n5 See also\n6 References\n"

# Read the first 200 characters of the second list
substr(ul_text[2], start = 1, stop = 200)

#> [1] "1.1 Human copy-and-paste\n1.2 Text pattern matching\n1.3 HTTP
#programming\n1.4 HTML parsing\n1.5 DOM parsing\n1.6 Vertical aggregation\n1.7
#Semantic annotation recognizing\n1.8 Computer vision web-page analy"


#--------------------------------------------
#  Approach 2 - pull all list elements (<li>)
#--------------------------------------------
# Pull the text contained in each list item for all the lists.

li_text <- wiki_scraping_page %>%
  html_nodes("li") %>%
  html_text()

length(li_text)
## [1] 161

li_text[1:3]
#> [1] "1 Techniques\n1.1 Human copy-and-paste\n1.2 Text pattern matching\n1.3
#> HTTP programming\n1.4 HTML parsing\n1.5 DOM parsing\n1.6 Vertical
#> aggregation\n1.7 Semantic annotation recognizing\n1.8 Computer vision web-page
#> analysis\n"  
#> [2] "1.1 Human copy-and-paste" 
#> [3] "1.2 Text pattern matching"

# At this point we may believe we have all the text desired and proceed with
# joining the paragraph (p_text) and list (ul_text or li_text) character strings
# and then perform the desired textual analysis. 

# However, we may now have captured more text than we were hoping for. 

# For example, by scraping all lists we are also capturing the listed links in
# the left margin of the webpage. If we look at the 104-136 list items that we
# scraped, we’ll see that these texts correspond to the left margin text.

li_text[54:71]  # section: See also
li_text[72:96]  # section: References 
li_text[97:161]  # navigation links and others


#------------------------------------------------------------------
#  1.2.4 Scraping HTML Nodes - all text with <div> nodes
#------------------------------------------------------------------

# If we desire to scrape every piece of text on the webpage than this won’t be of concern. 
# In fact, if we want to scrape all the text regardless of the content they represent 
# there is an easier approach. 

# We can capture all the content to include text in paragraph (<p>), lists (<ul>, <ol>, 
# and <li>), and even data in tables (<table>) by using <div>. 
# This is because these other elements are usually a subsidiary of an HTML division 
# or section so pulling all <div> nodes will extract all text contained in that division 
# or section regardless if it is also contained in a paragraph or list.

all_text <- wiki_scraping_page %>%
  html_nodes("div") %>% 
  html_text()

length(all_text)
## 570
## see sizes of text char in all <div> nodes
stringr::str_length(all_text)


# Read the first 200 characters of the third div nodes list
substr(all_text[3], start = 1, stop = 200) 
# Read from 483 character to 1500 chatacter of the third div nodes list
substr(all_text[3], start = 483, stop = 1500)


#------------------------------------
#  1.2.5 Scraping Specific HTML Nodes
#------------------------------------

# However, if we are concerned only with specific content on the webpage then we
# need to make our HTML node selection process a little more focused. To do this
# we, we can use our browser’s developer tools to examine the webpage we are
# scraping and get more details on specific nodes of interest. 

# If you are using Chrome or Firefox you can open the developer tools by
# clicking F12 (Cmd + Opt + I for Mac) or for Safari you would use
# Command-Option-I. 

# An additional option which is recommended by Hadley Wickham is to use
# selectorgadget.com, a Chrome extension, to help identify the web page elements
# you need1.

# Once the developers tools are opened your primary concern is with the element
# selector. This is located in the top lefthand corner of the developers tools
# window.

# Once you’ve selected the element selector you can now scroll over the elements
# of the webpage which will cause each element you scroll over to be
# highlighted. Once you’ve identified the element you want to focus on, select
# it. This will cause the element to be identified in the developer tools
# window. 

# For example, if I am only interested in the main body of the Web Scraping
# content on the Wikipedia page then I would select the element that highlights
# the entire center component of the webpage. This highlights the corresponding
# element <div id="bodyContent" class="mw-body-content"> in the developer tools
# window as the following illustrates.

# I can now use this information to select and scrape all the text from this
# specific <div> node by calling the ID name (“#mw-content-text”) in
# html_nodes()

# As you can see below, the text that is scraped begins with the
# first line in the main body of the Web Scraping content and ends with the text
# in the See Also section which is the last bit of text directly pertaining to
# Web Scraping on the webpage. 

# Explicitly, we have pulled the specific text associated with the web content
# we desire.
  
body_text <- wiki_scraping_page %>%
  html_nodes("#mw-content-text") %>% 
  html_text()
                                                                                                                        
# read the first 207 characters
substr(body_text, start = 1, stop = 207)

#> "\n\n\nThis article needs additional citations for verification. Please help
#> improve this article by adding citations to reliable sources. Unsourced
#> material may be challenged and removed. (June 2017) (Learn how"

# read the last 73 characters
substr(body_text,
       start = nchar(body_text) - 73,
       stop = nchar(body_text))

#> [1] "Australian Communications Authority. p. 20. Retrieved 2009-03-09. \n\n\n\n\n\n\n\n"

# Using the developer tools approach allows us to be as specific as we desire.
# We can identify the class name for a specific HTML element and scrape the text
# for only that node rather than all the other elements with similar tags. 
# This allows us to scrape the main body of content as we just illustrated or we
# can also identify specific headings, paragraphs, lists, and list components if
# we desire to scrape only these specific pieces of text:

# Scraping a specific heading
wiki_scraping_page %>%
  html_nodes("#Techniques") %>%
  html_text()
## [1] "Techniques"

# Scraping a specific paragraph
wiki_scraping_page %>%
  html_nodes("#mw-content-text p:nth-child(57)") %>%
  html_text()
## [1] "In Australia, the Spam Act 2003 outlaws some forms of web harvesting, although this only applies to email addresses.[20][21]"

# Scraping a specific list - e.g. section: See also
wiki_scraping_page %>%
  html_nodes("#mw-content-text .column-count-3 li") %>%
  # html_nodes(".column-count-3 li") %>% ## is OK too
  html_text()

#> [1] "Archive.is"                                                                                                                                                                                                                                                                                                
#> [2] "Comparison of feed aggregators" 
#> [3] ...

# Scraping a specific reference list item
wiki_scraping_page %>%
  html_nodes("#cite_note-22") %>%
  html_text()
#> [1] "^ \"High Court of Ireland Decisions >> Ryanair Ltd -v- Billigfluege.de GMBH 2010 IEHC 47 (26 February 2010)\". British and Irish Legal Information Institute. 2010-02-26. Retrieved 2012-04-19. "


#------------------------------------------------
#  1.3  Cleaning-up the text from selected nodes
#------------------------------------------------

# With any webscraping activity, especially involving text, there is likely to
# be some clean-up involved. 

# For example, in the previous example we saw that we can specifically pull the 
# list of See also; however, you can see that in between each list item
# rather than a space there contains one or more \n which is used in HTML to
# specify a new line. We can clean this up quickly with a little character
# string manipulation.


#------------------------------------
#  1.3.1  Cleaning-up \n (a new line)
#------------------------------------

library(magrittr)

wiki_scraping_page %>%
  html_nodes(".div-col") %>% ## using CCS class name
  html_text()

#> [1] "\nArchive.is\nComparison of feed aggregators\nData scraping\nData
#wrangling\nImporter\nJob wrapping\nKnowledge extraction\nOpenSocial\nScraper
#site\nFake news website\nBlog scraping\nSpamdexing\nDomain name drop list\nText
#corpus\nWeb archiving\nBlog network\nSearch Engine Scraping\nWeb crawlers\n"


# Clean-up "\n" and remove empty values
wiki_scraping_page %>%
  html_nodes(".div-col") %>% ## using CCS class name
  html_text() %>% 
  strsplit(split = "\n") %>% ## split on "\n"
  unlist() %>% ## unlist to char vector
  .[. != ""] ## remove empty values ("" or character(0)) using magrittr
#> [1] "Archive.is"                     "Comparison of feed aggregators"
#> [3] "Data scraping"                  "Data wrangling"                
#> [5] "Importer"                       "Job wrapping"                  
#> [7] "Knowledge extraction"           "OpenSocial"                    
#> [9] "Scraper site"                   "Fake news website"             
#> [11] "Blog scraping"                  "Spamdexing"                    
#> [13] "Domain name drop list"          "Text corpus"                   
#> [15] "Web archiving"                  "Blog network"                  
#> [17] "Search Engine Scraping"         "Web crawlers"        


#--------------------------------------------------------------------------
#  1.3.2  Cleaning-up extra characters (i.e. \n,  \, ^) in text with RegEx
#--------------------------------------------------------------------------

# Similarly, as we saw in our example above with scraping the main body content 
# (body_text), there are extra characters (i.e. \n,  \, ^) in the text that we
# may not want. 

# Using a little regex we can clean this up so that our character string 
# consists of only text that we see on the screen and no additional HTML code 
# embedded throughout the text.

library(stringr)

# read the last 700 characters
substr(body_text,
       start = nchar(body_text) - 700,
       stop = nchar(body_text))
#> [1] "reland Decisions >> Ryanair Ltd -v- Billigfluege.de GMBH 2010 IEHC 47
#> (26 February 2010)\". British and Irish Legal Information Institute.
#> 2010-02-26. Retrieved 2012-04-19. \n^ Matthews, Áine (June 2010).
#> \"Intellectual Property: Website Terms of Use\". Issue 26: June 2010. LK
#> Shields Solicitors Update. p. 03. Retrieved 2012-04-19. \n^ National Office for
#> the Information Economy (February 2004). \"Spam Act 2003: An overview for
#> business\" (PDF). Australian Communications Authority. p. 6. Retrieved
#> 2009-03-09. \n^ National Office for the Information Economy (February 2004).
#> \"Spam Act 2003: A practical guide for business\" (PDF). Australian
#> Communications Authority. p. 20. Retrieved 2009-03-09. \n\n\n\n\n\n\n\n"

# clean up text with RegEX
body_text %>%
  stringr::str_replace_all(pattern = "\n", replacement = " ") %>% ## \n symbol
  stringr::str_replace_all(pattern = "[\\^]", replacement = " ") %>% ## ^ symbol
  stringr::str_replace_all(pattern = "\"", replacement = " ") %>% ## " symbol
  stringr::str_replace_all(pattern = "\\s+", replacement = " ") %>% ## any whitespace (e.g. space, tab, newline)
  stringr::str_trim(side = "both") %>%
  substr(start = nchar(body_text) -
           700, stop = nchar(body_text))
#> [1] "Institute. 2010-02-26. Retrieved 2012-04-19. Matthews, Áine (June 2010).
# Intellectual Property: Website Terms of Use . Issue 26: June 2010. LK Shields
# Solicitors Update. p. 03. Retrieved 2012-04-19. National Office for the
# Information Economy (February 2004). Spam Act 2003: An overview for business
# (PDF). Australian Communications Authority. p. 6. Retrieved 2009-03-09.
# National Office for the Information Economy (February 2004). Spam Act 2003: A
# practical guide for business (PDF). Australian Communications Authority. p. 20.
# Retrieved 2009-03-09."

## Character classes and alternatives
# There are a number of special patterns that match more than one character. 
#  .      : matches any character apart from a newline
#  \d     : matches any digit.
#  \s     : matches any whitespace (e.g. space, tab, newline).
#  [abc]  : matches a, b, or c.
#  [^abc] : matches anything except a, b, or c.
# Remember, to create a regular expression containing \d or \s, you’ll need 
# to escape the \ for the string, so you’ll type "\\d" or "\\s".


#-----------------------------------------------
#  1.4.  Scraping data in tables from HTML
#-----------------------------------------------

# The Cast data are in tabular form 
# in the first table on the page. 
# Use html_node() and [[ to find it, then coerce it to a data frame with html_table():

# Store web url
lego_movie <- html("http://www.imdb.com/title/tt1490017/")

lego_movie_cast_tbl <-
  lego_movie  %>%
  html_nodes("table") %>%
  .[[1]] %>%
  html_table()

dim(lego_movie_cast_tbl)
lego_movie_cast_tbl

# TBD: clean up text in table with RegEX
# lego_movie_cast_tbl %>%
#   sapply(stringr::str_replace_all(pattern = "\n", replacement = " ")) ## \n symbol
#   
# lego_movie_cast_tbl
# 
#   
#   stringr::str_replace_all(pattern = "[\\^]", replacement = " ") %>% ## ^ symbol
#   stringr::str_replace_all(pattern = "\"", replacement = " ") %>% ## " symbol
#   stringr::str_replace_all(pattern = "\\s+", replacement = " ") %>% ## any whitespace (e.g. space, tab, newline)
#   stringr::str_trim(side = "both") %>%
  


#-----------------------------------------------
#  1.5.Scraping links from HTML Attribues
#-----------------------------------------------

# Get the text of links to other languages wiki pages
wiki_scraping_page %>%
  html_nodes("#p-lang .interlanguage-link") %>% ## using CCS class name
  html_text()

wiki_scraping_page %>%
  html_nodes(".interlanguage-link-target") %>% ## using CCS class name
  html_text()


# Search for tags nodes for links
wiki_scraping_page %>%
  html_nodes("#p-lang .interlanguage-link") %>% ## using CCS class name
  html_name()
## a level too high

# Search for attributes of <a> tag / node for info about links
wiki_scraping_page %>%
  html_nodes("#p-lang .interlanguage-link") %>% ## using CCS class name
  html_node("a") %>% ##look for links with <a> tag
  html_attrs() ## show all attrs

wiki_scraping_page %>%
  html_nodes(".interlanguage-link-target") %>% ## using CCS class name
  html_attrs() ## show all attrs


#> [[1]]
# href 
# "https://ar.wikipedia.org/wiki/%D8%AA%D9%82%D8%B4%D9%8A%D8%B1_%D8%A7%D9%84%D9%88%D9%8A%D8%A8" 
# title 
# "تقشير الويب – Arabic" 
# lang 
# "ar" 
# hreflang 
# "ar" 
# class 
# "interlanguage-link-target" 
# 
# [[2]]
# href                                        title 
# "https://ca.wikipedia.org/wiki/Web_scraping"                     "Web scraping – Catalan" 
# lang                                     hreflang 
# "ca"                                         "ca" 
# class 
# "interlanguage-link-target" 
# 
# [[3]]
# ...  html_attrs()


# Get links with <a herf> attribute for <a> tag 
wiki_scraping_page %>%
  html_nodes("#p-lang .interlanguage-link") %>% ## using CCS class name
  html_node("a") %>% ##look for links with <a> tag
  html_attr("href") #%>% ## show all url / http addresess

wiki_scraping_page %>%
  html_nodes(".interlanguage-link-target") %>% ## using CCS class name
  html_attr("href") #%>% ## show all url / http addresess

#> [1] "https://ar.wikipedia.org/wiki/%D8%AA%D9%82%D8%B4%D9%8A%D8%B1_%D8%A7%D9%84%D9%88%D9%8A%D8%A8"                             
#> [2] "https://ca.wikipedia.org/wiki/Web_scraping"                                                                              
#> [3] "https://de.wikipedia.org/wiki/Screen_Scraping" 
#> ...


# Get links'titles with <a = title> attribute for <a> tag 
wiki_scraping_page %>%
  html_nodes("#p-lang .interlanguage-link") %>% ## using CCS class name
  html_node("a") %>% ##look for links with <a> tag
  html_attr("title") #%>% ## show all attrs

wiki_scraping_page %>%
  html_nodes(".interlanguage-link-target") %>% ## using CCS class name
  html_attr("title") #%>% ## show all attrs

#> [1] "تقشير الويب – Arabic"            "Web scraping – Catalan"         
#> [3] "Screen Scraping – German"        "Web scraping – Spanish"         
#> [5] "Web scraping – Basque"           "Web scraping – French"          
#> [7] "Vefsöfnun – Icelandic"           "Web scraping – Italian"         
#> [9] "Rasmošana – Latvian"             "Scrapen – Dutch"                
#> [11] "ウェブスクレイピング – Japanese" "Web scraping – Serbian"         
#> [13] "Web kazıma – Turkish"            "Web scraping – Ukrainian"

#----------------------------------------------
# Other popular options for html_attr():
#----------------------------------------------

#  html_attr("src")
#  html_attr("alt")

# Store web url
lego_movie <- html("http://www.imdb.com/title/tt1490017/")

# Scrape the website for the movie rating
rating <- lego_movie %>% 
  html_nodes("strong span") %>%
  html_text() %>%
  as.numeric()
rating
#> [1] 7.8

# Scrape the website for the cast
cast <- lego_movie %>%
  html_nodes("#titleCast .itemprop span") %>%
  html_text()
cast
##  [1] "Will Arnett"     "Elizabeth Banks" "Craig Berry"    
##  [4] "Alison Brie"     "David Burrows"   "Anthony Daniels"
##  [7] "Charlie Day"     "Amanda Farinos"  "Keith Ferguson" 
## [10] "Will Ferrell"    "Will Forte"      "Dave Franco"    
## [13] "Morgan Freeman"  "Todd Hansen"     "Jonah Hill"

# Scrape the website for the <img src=""> attribute of the movie poster
lego_poster_src <- lego_movie %>%
  html_nodes(".poster a img") %>% ##
  # html_nodes("div .poster a img") %>% ## works
  # html_nodes("[itemprop='image']") %>% ## too general
  # html_attrs()
  html_attr("src")  
lego_poster_src

# Scrape the website for the <img alt=""> attribute of the movie poster
lego_poster_alt <- lego_movie %>%
  html_nodes(".poster a img") %>% ##
  # html_attrs()
  html_attr("alt")
lego_poster_alt


#------------------------
# Adv topics

#===============================================================================
# ADV_1 - .. by iterating in parallel through data

# There are cases when you parse a document where a node might not be optional
# and it is perfectly fine to have an empty result. It should be possible to
# give an additional parameter to for example html_node not to throw an
# error/warning if there is no match.

# The challenge is then if I want only 1 (the first) occurence (or none if no match exists).
# html_nodes gives me all. Using %>% extract2(1) only works if there is minimum 1 match.
# html_node would give me the first occurence (but again a warning if there are several matches.
                                             
# I was trying to update the Zillow demo, but currently one of the houses doesn't have a lot size item. I can't use html_nodes() or html_node_first() because I want to keep sqft in line with the other data.

# I've tried to save the page as it exists now, so hopefully this is reproducible.

library(rvest)
library(dplyr)

url <- "https://dl.dropboxusercontent.com/u/2019891/zillow_example.html"

houses <- read_html(url) %>%
  html_nodes("article")

# Year works okay because there is exactly one per house
year_build <- houses %>%
  html_node(".built-year") %>%
  html_text() %>%
  tidyr::extract_numeric()

year_build
# But the 11th house is missing .lot-size, so I can't get one item for each house
sqft <- houses %>%
  html_node(".lot-size") %>%
  html_text()
#> Error: No matches

sqft <- houses %>%
  html_nodes(".lot-size") %>%
  html_text()

length(sqft)
#> [1] 24

data.frame(year = year_build, sqft = sqft)
#> Error in data.frame(year = year_build, sqft = sqft): arguments imply differing number of rows: 25, 24

# The issue which user gergness describes can be covered by iterating in parallel through the houses:
  
getYearAndSqft <- function(node) {
    year_build <- node %>%
      html_nodes(".built-year") %>%
      html_text %>%
      tidyr::extract_numeric()
    sqft <- node %>% 
      html_nodes(".lot-size") %>%
      html_text
    
    list(year_build=year_build,sqft=sqft) ## iterating in parallel 
  }

df <- houses %>% 
  lapply(getYearAndSqft) %>%
  do.call(rbind, .) %>% 
  as.data.frame

> head(df, n=13) 
  %>% tail(n=5)
#    year_build                sqft
# 9        1992     â€¢ 0.36 ac lot
# 10       1995  â€¢ 6,534 sqft lot
# 11       2014                    
# 12       1980     â€¢ 0.40 ac lot
# 13       1967     â€¢ 0.26 ac lot

# Also here if you would get more than one year or sqft back per house 
# you'd have duplicated rows from using html_nodes 
# - which would be needed to be taken care of separately. 
# Having a function like html_node_first would make this more canonical.

#===============================================================================

# ADV_2 html_text() - storing an NA value if it does not find an attribute

# create a new function to wrap error handling, it'll keep the %>% pipe cleaner and easier to grok for your future self and others:

library(rvest)

html_text_na <- function(x, ...) {
  txt <- try(html_text(x, ...))
  if (inherits(txt, "try-error") |
      (length(txt) == 0)) {
    return(NA)
  }
  return(txt)
  
}

base_url <-
  "http://www.saem.org/membership/services/residency-directory?RecordID=%d"

record_id <- c(1291, 1000, 1166, 1232, 999)

sapply(record_id, function(i) {
  read_html(sprintf(base_url, i)) %>%
    html_nodes("#drpict tr:nth-child(6) .text") %>%
    html_text_na %>%
    as.numeric()
  
})

#=============================================================================

# ADV_3 - Select nodes from paginated content

# Oftentimes, content is paginated into multiple HTML documents. When the number
# of HTML documents is known and their corresponding URLs can be generated
# beforehand, then selecting the desired nodes is a matter of combining
# xml2::read_html() and rvest::html_nodes() with, say, purrr::map().

# When the number of HTML documents is unknown or when their corresponding URLs
# cannot be generated beforehand we need a different approach. One approach is
# to "click" the More button using rvest::follow_link() and recursion. I
# recently implemented this approach as follows:
  
library(rvest)

html_more_nodes <- function(session, css, more_css) {
  xml2:::xml_nodeset(c(
    html_nodes(session, css),
    tryCatch({
      html_more_nodes(follow_link(session, css = more_css),
                      css, more_css)
    }, error = function(e) NULL)
  ))
}

# Follow "More" link to get all stories on Hacker News
html_session("https://news.ycombinator.com") %>%
  html_more_nodes(".storylink", ".morelink") %>%
  html_text()




#------------------------------------
# some links:
#  https://stat4701.github.io/edav/2015/04/02/rvest_tutorial/