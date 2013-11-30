#!/usr/bin/env ruby


gem 'nokogiri', '~> 1.6.0'

require 'nokogiri' # for parsing the MediaWiki XML export file


#XPATH_TO_MARKUP_TEXT = '//xmlns:page//xmlns:revision//xmlns:text'

def get_xml_file_handle(source_xml)
  doc = Nokogiri::XML(File.open(source_xml)) do |config|
    config.strict.strict
    config.strict.nonet
  end

  p 'XML Document is well-formed.' if doc.errors.empty?
  p "Document contains #{doc.xpath('//xmlns:page').count} wiki pages."

  doc
end
