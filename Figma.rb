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
    
                # Retrieve 1x and 2x scale images
                @srcset = Array.new

                for scale in 1..2 do
                    # Generate a Figma API request URL
                    api_url = URI.parse("#{BASE_URL}#{@document}?ids=#{@frame}&scale=#{scale}")
                    @srcset.push(request(api_url))
                end
                
                "<img srcset=\"#{@srcset[0]} 1x, #{@srcset[1 ]} 2x\" class=\"figma\"/>"
            end

            def request(url)
                # Compose the request parameters
                http = Net::HTTP.new(url.host, url.port)
                http.use_ssl = true
                puts "\tFigma: Requesting frame #{@frame} from document id #{@document}...\n"

                # Make the request 
                response = http.get(url, 'X-Figma-Token' => TOKEN)
                figma = JSON.parse(response.body)

                # Simplistic error checking on the response content
                begin
                    image = figma["images"][@frame]
                rescue
                    if figma["status"]
                        raise "Figma API error #{figma['status']}: #{figma['err']}."
                    end
                end
                
                return image
            end
        end
    end
end

Liquid::Template.register_tag("figma", Jekyll::Figma::FigmaTag)
