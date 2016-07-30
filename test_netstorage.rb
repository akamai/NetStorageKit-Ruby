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


require "securerandom"
require "test/unit"

require "akamai/netstorage"
# require_relative "lib/akamai/netstorage"
# require "nokogiri"


NS_HOSTNAME = "astin-nsu.akamaihd.net"
NS_KEYNAME = "astinastin"
require_relative "spike/secrets" 
NS_KEY = KEY # DO NOT EXPOSE IT
NS_CPCODE = "360949"


class TestNetstorage < Test::Unit::TestCase
    def setup
        @temp_ns_dir = "/#{NS_CPCODE}/#{SecureRandom.uuid}"
        @temp_file = "#{SecureRandom.uuid}.txt"
        @temp_ns_file = "#{@temp_ns_dir}/#{@temp_file}"

        @ns = Akamai::Netstorage.new(NS_HOSTNAME, NS_KEYNAME, NS_KEY)
    end

    def teardown
        # delete temp files for local
        if File.exists?(@temp_file)
            File.delete(@temp_file)
            puts "[TEARDOWN] remove #{@temp_file} from local done"
        end

        if File.exists?("#{@temp_file}_rename")
            File.delete("#{@temp_file}_rename")
            puts "[TEARDOWN] remove #{@temp_file}_rename from local done"
        end

        # delete temp files for netstorage
        ok, _ = @ns.delete(@temp_ns_file)
        if ok
            puts "[TEARDOWN] delete #{@temp_ns_file} done"
        end
        ok, _ = @ns.delete("#{@temp_ns_file}_lnk")
        if ok
            puts "[TEARDOWN] delete #{"#{@temp_ns_file}_lnk"} done"
        end
        ok, _ = @ns.delete("#{@temp_ns_file}_rename")
        if ok
            puts "[TEARDOWN] delete #{"#{@temp_ns_file}_rename"} done"
        end
        ok, _ = @ns.rmdir(@temp_ns_dir)
        if ok
            puts "[TEARDOWN] rmdir #{"#{@temp_ns_dir}"} done"
        end
    end

    def test_netstorage
        # dir
        ok, _ = @ns.dir("/#{NS_CPCODE}")
        assert_equal(true, ok, "dir fail")
        puts "[TEST] dir /#{NS_CPCODE} done"

        # mkdir
        ok, _ = @ns.mkdir(@temp_ns_dir)
        assert_equal(true, ok, "mkdir fail")
        puts "[TEST] mkdir #{@temp_ns_dir} done"

        # upload
        File::open(@temp_file, 'w') { |f| 
            f << "Hello, Netstorage API World!"
        }
        ok, _ = @ns.upload(@temp_file, @temp_ns_file)
        assert_equal(true, ok, "upload fail")
        puts "[TEST] upload #{@temp_file} to #{@temp_ns_file} done"
        
        # du
        ok, res = @ns.du(@temp_ns_dir)
        assert_equal(true, ok, "du fail")
        # doc = Nokogiri::XML(res.body)
        # assert_equal(File.size(@temp_file).to_s, doc.at('du-info').attributes['bytes'].value)
        puts "[TEST] du done"

        # mtime
        current_time = Time.now.to_i
        ok, _ = @ns.mtime(@temp_ns_file, current_time)
        assert_equal(true, ok, "mtime fail")
        puts "[TEST] mtime #{@temp_ns_file} to #{current_time} done"

        # stat
        ok, res = @ns.stat(@temp_ns_file)
        assert_equal(true, ok, "stat fail")
        # doc = Nokogiri::XML(res.body)
        # assert_equal(current_time.to_s, doc.at('file').attributes['mtime'].value)
        puts "[TEST] stat done"

        # symlink
        ok, _ = @ns.symlink(@temp_ns_file, "#{@temp_ns_file}_lnk")
        assert_equal(true, ok, "symlink fail")
        puts "[TEST] symlink #{@temp_ns_file} to #{@temp_ns_file}_lnk done"

        # rename
        ok, _ = @ns.rename(@temp_ns_file, "#{@temp_ns_file}_rename")
        assert_equal(true, ok, "rename fail")
        puts "[TEST] rename #{@temp_ns_file} to #{@temp_ns_file}_rename done"

        # download
        ok, _ = @ns.download("#{@temp_ns_file}_rename")
        assert_equal(true, ok, "download fail")
        puts "[TEST] download #{@temp_ns_file}_rename done"

        # delete
        ok, _ = @ns.delete("#{@temp_ns_file}_rename")
        assert_equal(true, ok, "delete fail")
        puts "[TEST] delete #{@temp_ns_file}_rename done"
        ok, _ = @ns.delete("#{@temp_ns_file}_lnk")
        assert_equal(true, ok, "delete fail")
        puts "[TEST] delete #{@temp_ns_file}_lnk done"

        # rmdir
        ok, _ = @ns.rmdir(@temp_ns_dir)
        assert_equal(true, ok, "rmdir fail.")
        puts "[TEST] rmdir #{@temp_ns_dir} done"
    end
end