#!/usr/bin/ruby

# Original author: Astin Choi <achoi@akamai.com>

# Copyright 2016 Akamai Technologies http://developer.akamai.com.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "base64"
require "cgi"
require "net/http"
require "openssl" 
require "uri"


module Akamai
    class Netstorage
        attr_accessor :hostname, :keyname, :key
        attr_reader :request

        def initialize(hostname, keyname, key)
            @hostname = hostname
            @keyname = keyname
            @key = key
            @request = nil
        end

        private

        def _response(uri, kwargs)
            if kwargs[:action] == "download"
                local_destination = kwargs[:destination]
                if kwargs[:path]
                    ns_filename = kwargs[:path][-1] != '/' ? File.basename(kwargs[:path]) : nil
                    if local_destination == ''
                        local_destination = ns_filename
                    elsif File.directory?(local_destination)
                        local_destination = File.join(local_destination, ns_filename)
                    end
                end
                response = Net::HTTP.start(uri.hostname, uri.port) { |http| 
                    http.request @request do |res|
                        open(local_destination, "wb") do |io|
                            res.read_body do |chunk|
                                io.write chunk
                            end
                        end
                    end
                }
            elsif kwargs[:action] == "upload"
                @request.body = File.read(kwargs[:source])
                response = Net::HTTP.start(uri.hostname, uri.port) { |http| 
                        http.request(@request) 
                }
            else 
                response = Net::HTTP.start(uri.hostname, uri.port) { |http| 
                        http.request(@request) 
                }
            end        
            return response
        end
        
        def _request(kwargs={})
            path = URI::escape(kwargs[:path])
            acs_action = "version=1&action=#{kwargs[:action]}"
            acs_auth_data = "5, 0.0.0.0, 0.0.0.0, #{Time.now.to_i}, #{Random.rand(100000)}, #{@keyname}"
            sign_string = "#{path}\nx-akamai-acs-action:#{acs_action}\n"
            message = acs_auth_data + sign_string

            hash_ = OpenSSL::HMAC.digest("sha256", @key, message)
            acs_auth_sign = Base64.encode64(hash_).rstrip

            uri = URI("http://#{@hostname}#{path}")
            headers = {
                'X-Akamai-ACS-Action' => acs_action,
                'X-Akamai-ACS-Auth-Data' => acs_auth_data,
                'X-Akamai-ACS-Auth-Sign' => acs_auth_sign,
                'Accept-Encoding' => "identity"
            }

            if kwargs[:method] == "GET"
                @request = Net::HTTP::Get.new(uri, initheader=headers)
            elsif kwargs[:method] == "POST" 
                @request = Net::HTTP::Post.new(uri, initheader=headers)
            elsif kwargs[:method] == "PUT" # Use only upload
                @request = Net::HTTP::Put.new(uri, initheader=headers)
            end

            response = _response(uri, kwargs)
            
            return response.code == "200", response
        end

        public

        def dir(ns_path)
            return _request(action: "dir&format=xml",
                            method: "GET",
                            path: ns_path)
        end

        def download(ns_source, local_destination='')
            return _request(action: "download",
                            method: "GET",
                            path: ns_source,
                            destination: local_destination)
        end

        def du(ns_path)
            return _request(action: "du&format=xml",
                            method: "GET",
                            path: ns_path)
        end

        def stat(ns_path)
            return _request(action: "stat&format=xml",
                            method: "GET",
                            path: ns_path)
        end

        def mkdir(ns_path)
            return _request(action: "mkdir",
                            method: "POST",
                            path: ns_path)
        end

        def rmdir(ns_path)
            return _request(action: "rmdir",
                            method: "POST",
                            path: ns_path)
        end

        def mtime(ns_path, mtime)
            return _request(action: "mtime&format=xml&mtime=#{mtime}",
                            method: "POST",
                            path: ns_path)
        end

        def delete(ns_path)
            return _request(action: "delete",
                            method: "POST",
                            path: ns_path)
        end

        def quick_delete(ns_path)
            return _request(action: "quick-delete&quick-delete=imreallyreallysure",
                            method: "POST",
                            path: ns_path)
        end

        def rename(ns_target, ns_destination)
            return _request(action: "rename&destination=#{CGI::escape(ns_destination)}",
                            method: "POST",
                            path: ns_target)
        end

        def symlink(ns_target, ns_destination)
            return _request(action: "symlink&target=#{CGI::escape(ns_target)}",
                            method: "POST",
                            path: ns_destination)
        end

        def upload(local_source, ns_destination)
            if File.file?(local_source) && ns_destination[-1] == "/" 
                ns_destination = "#{ns_destination}#{File.basename(local_source)}"
            end
            return _request(action: "upload",
                            method: "PUT",
                            source: local_source,
                            path: ns_destination) 
        end
    end
end