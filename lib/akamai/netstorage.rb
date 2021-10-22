#!/usr/bin/ruby

# Original author: Astin Choi <achoi@akamai.com>

# Copyright 2018 Akamai Technologies http://developer.akamai.com.

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
    class NetstorageError < Exception
        """Base-class for all exceptions raised by Netstorage Class"""
    end


    class Netstorage
        attr_accessor :hostname, :keyname, :key, :ssl
        attr_reader :request

        def initialize(hostname, keyname, key, ssl=false)
            if hostname == '' || keyname == '' || key == ''
                raise NetstorageError, '[NetstorageError] You should input netstorage hostname, keyname and key all'
            end

            @hostname = hostname
            @keyname = keyname
            @key = key
            @ssl = ssl ? 's' : ''

            @request = nil
        end

        private

        def _response(uri, kwargs)
            if kwargs[:action] == "download"
                local_destination = kwargs[:destination]
                
                if local_destination == ''
                    local_destination = File.basename(kwargs[:path])
                elsif File.directory?(local_destination)
                    local_destination = File.join(local_destination, File.basename(kwargs[:path]))
                end
                
                response = Net::HTTP.start(uri.hostname, uri.port, 
                  :use_ssl => uri.scheme == 'https') { |http| 
                    http.request @request do |res|
                        begin
                            open(local_destination, "wb") do |io|
                                res.read_body do |chunk|
                                    io.write chunk
                                end
                            end
                        rescue Exception => e
                            raise NetstorageError, e
                        end
                    end
                }
                return response
            end

            if kwargs[:action].start_with?("upload")
                begin
                    @request.body = File.read(kwargs[:source])
                rescue Exception => e
                    raise NetstorageError, e
                end 
            end 
            
            response = Net::HTTP.start(uri.hostname, uri.port, 
              :use_ssl => uri.scheme == 'https') { |http| 
                    http.request(@request) 
            }

            return response
        end
        
        def _request(kwargs={})
            path = kwargs[:path].to_s 
            if !path.start_with?('/')
                raise NetstorageError, '[NetstorageError] Invalid netstorage path'
            end

            path = URI::escape(kwargs[:path])
            acs_action = "version=1&action=#{kwargs[:action]}"
            acs_auth_data = "5, 0.0.0.0, 0.0.0.0, #{Time.now.to_i}, #{Random.rand(100000)}, #{@keyname}"
            sign_string = "#{path}\nx-akamai-acs-action:#{acs_action}\n"
            message = acs_auth_data + sign_string

            hash_ = OpenSSL::HMAC.digest("sha256", @key, message)
            acs_auth_sign = Base64.encode64(hash_).rstrip

            uri = URI("http#{@ssl}://#{@hostname}#{path}")
            headers = {
                'X-Akamai-ACS-Action' => acs_action,
                'X-Akamai-ACS-Auth-Data' => acs_auth_data,
                'X-Akamai-ACS-Auth-Sign' => acs_auth_sign,
                'Accept-Encoding' => 'identity',
                'User-Agent' => 'NetStorageKit-Ruby'
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

        def dir(ns_path, option={})
            return _request(action: "dir&format=xml&#{URI.encode_www_form(option)}",
                            method: "GET",
                            path: ns_path)
        end

        def list(ns_path, option={})
            return _request(action: "list&format=xml&#{URI.encode_www_form(option)}",
                            method: "GET",
                            path: ns_path)
        end

        def download(ns_source, local_destination='')
            if ns_source.end_with?('/')
                raise NetstorageError, "[NetstorageError] Nestorage download path shouldn't be a directory: #{ns_source}"
            end

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

        def upload(local_source, ns_destination, index_zip=false)
            if File.file?(local_source) 
                if ns_destination.end_with?('/')
                    ns_destination = "#{ns_destination}#{File.basename(local_source)}"
                end
            else
                raise NetstorageError, "[NetstorageError] #{ns_destination} doesn't exist or is directory"
            end
            action = "upload"
            if index_zip == true or index_zip.to_s.downcase == "true"
                action += "&index-zip=1"
            end

            return _request(action: action,
                            method: "PUT",
                            source: local_source,
                            path: ns_destination) 
        end
    end
end