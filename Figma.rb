require 'net/http'
require 'uri'
require 'json'

module Jekyll
    module Figma
        TOKEN = 'xxxx-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
        BASE_URL = 'https://api.figma.com/v1/images/'

        class FigmaTag < Liquid::Tag
            def initialize(tag_name, figma_url, tokens)
                super
                @url = URI.parse(figma_url.strip)
            end

            def render(context)

                # Identify document and frame from the source URL
                @document = @url.path.split("/")[2]
                @frame = URI.unescape(@url.query).split("=")[1]

                # Generate a Figma API request URL
                api_url = URI.parse("#{BASE_URL}#{@document}?ids=#{@frame}")
                
                # Make the request
                http = Net::HTTP.new(api_url.host, api_url.port)
                http.use_ssl = true
                response = http.get(api_url, 'X-Figma-Token' => TOKEN)

                figma = JSON.parse(response.body)

                begin
                    image = figma["images"][@frame]
                rescue
                    if figma["err"]
                        raise "Figma API error #{figma['status']}: #{figma['err']}."
                    end
                end

                "<img src=\"#{image}\" />"
            end
        end
    end
end

Liquid::Template.register_tag("figma", Jekyll::Figma::FigmaTag)
