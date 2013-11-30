#!/usr/bin/env ruby

require 'json'
require 'rest_client'
require 'uri' # for escaping page titles


SOURCE_DIRECTORY = ARGV.shift # eg '~/export_to_planio/images'
# TODO instead of demanding two parametes let the user provide a full project url and
# read the project name from it.
REDMINE_URL = ARGV.shift      # eg 'https://example.plan.io'
PROJECT_NAME = ARGV.shift     # eg 'test'
API_KEY = ARGV.shift          # eg 'ffff0000eeee1111dddd2222cccc3333bbbb4444'

upload_url = "#{REDMINE_URL}/uploads.json?key=#{API_KEY}"

FILE_DESCRIPTION = 'imported from MediaWiki'


p "Will process images in subdirectories of #{SOURCE_DIRECTORY} ..."
pages = Dir.glob("#{SOURCE_DIRECTORY}/*")

pages.each do |page_directory|
  associate_with_page = File.basename(page_directory)
  p "Processing images that should be associated with page #{associate_with_page} ..."

  images =  Dir.glob("#{page_directory}/*")

  images.each do |image|
    File.open(image, 'rb') do |f|

      file_name = File.basename(f)
      wiki_url = "#{REDMINE_URL}/projects/#{PROJECT_NAME}/wiki/#{URI.escape(associate_with_page)}.json?key=#{API_KEY}"
      p "Uploading #{associate_with_page}/#{file_name} ..."

      begin
        # First we upload the image to get an attachment token
        response = RestClient.post(upload_url, f, {:multipart => true, :content_type => 'application/octet-stream' })
        
      rescue RestClient::UnprocessableEntity => ue
        p "The following exception typically means that the file size of '#{file_name}' exceeds the limit configured in Redmine."
        raise ue

      end

      token = JSON.parse(response)['upload']['token']

      begin
        # Redmine will throw validation errors if you do not send a wiki content when attaching the image. So
        # we just get the current content and send that
        current_wiki_text = JSON.parse(RestClient.get(wiki_url))['wiki_page']['text']

      rescue RestClient::ResourceNotFound => rnf
        p "The following exception typically means that the wiki page ('#{associate_with_page}') for associating the image with is missing."
        raise rnf

      end


      begin
        response = RestClient.put(wiki_url, { :attachments => {
                                                :attachment1 => { # the hash key gets thrown away - name doesn't matter
                                                  :token => token,
                                                  :filename => file_name,
                                                  :description => FILE_DESCRIPTION # optional
                                                }
                                              },
                                              :wiki_page => {
                                                :text => current_wiki_text # wiki_text # original wiki text
                                              }
                                            })

      rescue RestClient::BadGateway => bg
        p "The following exception typically means that the targeted wiki page ('#{associate_with_page}') is actually a redirection to another page."
        raise bg

      end

    end
  end
end
