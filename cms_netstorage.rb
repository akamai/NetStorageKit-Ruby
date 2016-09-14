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


require "optparse"

require "akamai/netstorage"
# require_relative "lib/akamai/netstorage" 


action_options = <<ACTION_OPTIONS
        ## "123456" is CP(Content Provider) Code for Netstorage ##
        dir: to list the contents of the directory /123456
            dir /123456
        upload: to upload file.txt to /123456 directory
            upload file.txt /123456/ or
            upload file.txt /123456/file.txt
        stat: to display status of /123456/file.txt
            stat /123456/file.txt
        du: to display disk usage on directory /123456
            du /123456
        download: To download /123456/file.txt
            download /123456/file.txt or
            download /123456/file.txt LOCAL_PATH
        mtime: to set the timestamp of /123456/file.txt to 1463042904 in epoch format)
            mtime /123456/file.txt 1463042904
        quick-delete: to delete /123456/dir1 recursively (quick-delete needs to be enabled on the CP Code)
            quick-delete /123456/dir1
        rename: to rename /123456/file.txt to /123456/newfile.txt
            rename /123456/file.txt /123456/newfile.txt
        symlink: to create a symlink /123456/file.txt_symlink pointing to /123456/file.txt
            symlink /123456/file.txt /123456/file.txt_symlink
        delete: to delete /123456/file.txt
            delete /123456/file.txt
        mkdir: to create /123456/dir1
            mkdir /123456/dir1
        rmdir: to delete /123456/dir1 (directory needs to be empty)
            rmdir /123456/dir1
ACTION_OPTIONS


def print_result(request, response, action)
    puts "=== Request Header ==="
    puts "#{request.method} #{request.path}" 
    request.each_capitalized { |header, value| 
        puts "#{header}: #{value}" 
    } 

    puts "=== Response Header ===" 
    puts "#{response.code} #{response.message}" 
    response.each_capitalized { |header, value| 
        puts "#{header}: #{value}" 
    }

    if action != "download"
        puts "=== Response Body ===" 
        puts response.body
    end
end


options = {}

optparse = OptionParser.new do |opts|
    opts.banner = "Usage: ruby cms_netstorage.rb -H [hostname] -k [keyname] -K [key] -action [action_options] .."

    opts.on('-H', '--host host', 'Netstorage API hostname') do |host|
        options[:host] = host
    end

    opts.on('-k', '--keyname keyname', 'Netstorage API keyname') do |keyname|
        options[:keyname] = keyname
    end

    opts.on('-K', '--key key', 'Netstorage API key') do |key|
        options[:key] = key
    end

    opts.on('-a', '--action action', "action\n#{action_options}") do |action|
        options[:action] = action
    end

    opts.on('-h', '--help', 'display help') do
        puts opts
        exit
    end
end

begin
    optparse.parse!
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
    puts optparse
    exit
end

if options[:host] && options[:keyname] && options[:key] && options[:action]
    ns = Akamai::Netstorage.new(options[:host], options[:keyname], options[:key])
    
    
    if options[:action] == "delete"
        ok, response = ns.delete(ARGV.shift)
    elsif options[:action] == "dir"
        ok, response = ns.dir(ARGV.shift)
    elsif options[:action] == "download"
        ok, response = ns.download(ARGV.shift, (tmp = ARGV.shift) == nil ? '' : tmp)
    elsif options[:action] == "du"
        ok, response = ns.du(ARGV.shift)
    elsif options[:action] == "mkdir"
        ok, response = ns.mkdir(ARGV.shift)
    elsif options[:action] == "mtime"
        ok, response = ns.mtime(ARGV.shift, ARGV.shift)
    elsif options[:action] == "quick-delete"
        ok, response = ns.quick_delete(ARGV.shift)
    elsif options[:action] == "rmdir"
        ok, response = ns.rmdir(ARGV.shift)
    elsif options[:action] == "stat"
        ok, response = ns.stat(ARGV.shift)
    elsif options[:action] == "symlink"
        ok, response = ns.symlink(ARGV.shift, ARGV.shift)
    elsif options[:action] == "upload"
        ok, response = ns.upload(ARGV.shift, ARGV.shift)
    else 
        puts optparse
        exit
    end
    
    print_result(ns.request, response, options[:action])
else
    puts optparse
end