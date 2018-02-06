#!/usr/bin/env ruby

require 'bio'
Bio::NCBI.default_email = "tom.chappell@biogrammatics.com" # required for EUtils


current_dir = Dir.pwd

old_id_file = File.join(current_dir, "idnumbers.txt")
cumulative_id_file = File.join(current_dir, "cumulative_ids.txt")
html_file = File.join(current_dir, "pubmedtest.html")

puts old_id_file
puts cumulative_id_file
puts html_file

file = File.open(old_id_file, 'r')
oldids = file.read
oldidarray = oldids.split("\n")
file.close


abstract = %r{^%X ([^\n]+)}
link = %r{^%U ([^\n]+)}
title = %r{^%T ([^\n]+)}

idarray = Bio::PubMed::esearch("pichia pastoris", {"field" => "title/abstract", "reldate" => "120", "datetype" => "pdat", "retmax" => "1000"})

newids =  idarray.join("\n")

x = 1

unless (oldids == newids)

  addedidarray = idarray - oldidarray

  addedids = addedidarray.join("\n")

  File.open(old_id_file, 'w') {|f| f.write(newids) }

  File.open(cumulative_id_file, 'a') {|f| f.write("\n" + addedids) }

  sort_ids = `sort -nr cumulative_ids.txt -o cumulative_ids.txt`
  count_ids = `wc -l cumulative_ids.txt `

  puts count_ids

  idarraysize = idarray.length



  File.open(html_file, 'w') {|f| f.write("<h3>" + idarraysize.to_s + " Most Recent <i>Pichia</i> PubMed Citations (last 120 days)<h3>") }

  idarray.each do |id|

    pm = Bio::PubMed::efetch(id)
    med = Bio::MEDLINE.new(pm[0])         # MEDLINE object
    bib = med.reference.format("endnote")  # format is a method of Reference object
    trends = med.reference.format("science")
    bib.match(abstract)
    abstracttext = "<p>" + $1.to_s + "</p>"
    abstracttext.gsub!(/([A-Z ]+:)/,'</p><p><strong>\1</strong>')
    bib.match(title)
    titletext = $1.to_s
    bib.match(link)
    linktext = "<p><a href=" + $1.to_s + ">pubmed link</a></p>"

    pub_date = med.pubmed['DP']
    pub_date.chomp!
    x = 1

    File.open(html_file, 'a') {|f| f.write("<div itemscope itemtype=\"http://schema.org/ScholarlyArticle\"><hr><h4><span itemprop=\"headline\">" + titletext + "</span></h4> <p>" + trends + "</p> <span itemprop=\"datePublished\"><p>Publication date: " + pub_date + "</p></span> <span itemprop=\"url\">" + linktext + "</span> <details><summary>Abstract</summary>" + abstracttext + "</details></div>\n") }

  end

  File.open(html_file, 'a') {|f| f.write("\n") }

end

# git_write = `git commit -am "15 December 2017"`

