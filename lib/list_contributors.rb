#!/usr/bin/env ruby

require_relative 'common/xml_handler.rb'

SOURCE_XML = ARGV[0] # eg 'PATH_TO/mediawiki.xml'

def list_all_contributors(document)
  contributors_xpath = '//xmlns:page//xmlns:revision//xmlns:contributor'

  contributors = Array.new

  document.xpath(contributors_xpath).each do |c|
    contributor = c.css('username').text

		if contributor.empty?
    	p "Revision #{c.parent.css('id').text} of page '#{c.parent.parent.css('title').text}' has an undefined contributor. Upon import a fall back username will be used."
		else
    	unless contributors.include? contributor
     	  contributors << contributor
   	 	end
		end

  end

  p "Document has #{document.xpath(contributors_xpath).count} contributions authored by these #{contributors.count} contributors:"
  contributors.sort.each { |c| p c }
end

doc = get_xml_file_handle(SOURCE_XML)
list_all_contributors(doc)
