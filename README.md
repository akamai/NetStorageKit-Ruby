NetstorageAPI: Akamai Netstorage API for Ruby
===============================================

[![Gem Version](https://badge.fury.io/rb/netstorageapi.svg)](https://badge.fury.io/rb/netstorageapi)
[![Build Status](https://travis-ci.org/akamai/NetStorageKit-Ruby.svg?branch=master)](https://travis-ci.org/akamai/NetStorageKit-Ruby)
[![License](http://img.shields.io/:license-apache-blue.svg)](https://github.com/akamai/NetStorageKit-Ruby/blob/master/LICENSE)

  
NetstorageAPI is Akamai Netstorage (File/Object Store) API for Ruby 2.0+.
  
  
Installation
------------

To install Netstorage API for Ruby:  

```bash
$ gem install netstorageapi
```
  
  
Example
-------

```ruby
> require "akamai/netstorage"
> 
> NS_HOSTNAME = "astinobj-nsu.akamaihd.net"
> NS_KEYNAME = "astinobj"
> NS_KEY = "xxxxxxxxxx" # Don't expose NS_KEY on public repository.
> NS_CPCODE = "407617"
> 
> ns = Akamai::Netstorage.new(NS_HOSTNAME, NS_KEYNAME, NS_KEY, ssl=false) # ssl is optional (default: false)
> local_source = "hello.txt"
> netstorage_destination = "/#{NS_CPCODE}/hello.txt" # or "/#{NS_CPCODE}/" is same.
>
> ok, response = ns.upload(local_source, netstorage_destination)
=> [true, <#Net::HTTPOK 200 OK readbody=true>] # true means 200 OK; If false, it's not 200 OK 
> response.body
=> "<HTML>Request Processed</HTML>\n"
```
  
  
Methods
-------

```ruby
> ns.delete(NETSTORAGE_PATH)
>
> dir_option = {
*  :max_entries => INTEGER,
*  :start => '/start/path',
*  :end => '/end/path/',
*  :prefix => 'object-prefix',
*  :slash => 'both',
*  :encoding => 'utf-8'
* }
> ns.dir(NETSTORAGE_PATH, dir_option)
> ns.download(NETSTORAGE_SOURCE, LOCAL_DESTINATION)
> ns.du(NETSTORAGE_PATH)
>
> list_option = {
*  :max_entries => INTEGER,
*  :end => '/end/path/',
*  :encoding => 'utf-8'
* }
> ns.list(NETSTORAGE_PATH, list_option)
> ns.mkdir("#{NETSTORAGE_PATH}/#{DIRECTORY_NAME}")
> ns.mtime(NETSTORAGE_PATH, TIME) # ex) TIME: Time.now.to_i
> ns.quick_delete(NETSTORAGE_DIR) # needs to the privilege on the CP Code
> ns.rename(NETSTORAGE_TARGET, NETSTORAGE_DESTINATION)
> ns.rmdir(NETSTORAGE_DIR) # remove empty direcoty
> ns.stat(NETSTORAGE_PATH)
> ns.symlink(NETSTORAGE_TARGET, NETSTORAGE_DESTINATION)
> ns.upload(LOCAL_SOURCE, NETSTORAGE_DESTINATION, index_zip=false)
>  
> # INFO: return (true/false, Net::HTTP.. Object)
> #               true means 200 OK.
> # INFO: can "upload" Only a single file, not directory.
> #       To use 'INDEX_ZIP=True',
> #       Must turn on index_zip on your Netstorage configuration.
> # WARN: Can raise Akamai::NetstorageError from all methods.
```
  
  
Test
----

You can test all above methods with [unittest script](https://github.com/AstinCHOI/NetStorageKit-Ruby/blob/master/test_netstorage.rb)
(NOTE: You should input NS_HOSTNAME, NS_KEYNAME, NS_KEY and NS_CPCODE in the script):

```bash
$ ruby test/test_netstorage.rb
Loaded suite test/test_netstorage
Started
[TEST] dir /407617 done
[TEST] list /407617 done
[TEST] mkdir /407617/6d50bfa3-ea6e-4112-84ae-7ca9edce104e done
[TEST] upload 439a5ab1-9b44-4520-bef9-ccd817fd294a.txt to /407617/6d50bfa3-ea6e-4112-84ae-7ca9edce104e/439a5ab1-9b44-4520-bef9-ccd817fd294a.txt done
[TEST] du done
[TEST] mtime /407617/6d50bfa3-ea6e-4112-84ae-7ca9edce104e/439a5ab1-9b44-4520-bef9-ccd817fd294a.txt to 1528347989 done
[TEST] stat done
[TEST] symlink /407617/6d50bfa3-ea6e-4112-84ae-7ca9edce104e/439a5ab1-9b44-4520-bef9-ccd817fd294a.txt to /407617/6d50bfa3-ea6e-4112-84ae-7ca9edce104e/439a5ab1-9b44-4520-bef9-ccd817fd294a.txt_lnk done
[TEST] rename /407617/6d50bfa3-ea6e-4112-84ae-7ca9edce104e/439a5ab1-9b44-4520-bef9-ccd817fd294a.txt to /407617/6d50bfa3-ea6e-4112-84ae-7ca9edce104e/439a5ab1-9b44-4520-bef9-ccd817fd294a.txt_rename done
[TEST] download /407617/6d50bfa3-ea6e-4112-84ae-7ca9edce104e/439a5ab1-9b44-4520-bef9-ccd817fd294a.txt_rename done
[TEST] delete /407617/6d50bfa3-ea6e-4112-84ae-7ca9edce104e/439a5ab1-9b44-4520-bef9-ccd817fd294a.txt_rename done
[TEST] delete /407617/6d50bfa3-ea6e-4112-84ae-7ca9edce104e/439a5ab1-9b44-4520-bef9-ccd817fd294a.txt_lnk done
[TEST] rmdir /407617/6d50bfa3-ea6e-4112-84ae-7ca9edce104e done
[TEARDOWN] remove 439a5ab1-9b44-4520-bef9-ccd817fd294a.txt from local done
[TEARDOWN] remove 439a5ab1-9b44-4520-bef9-ccd817fd294a.txt_rename from local done
.
[TEST] Invalid ns path NetstorageError test done
[TEST] Invalid upload local path NetstorageError test done
[TEST] Download directory path NetstorageError test done
.
Finished in x.xxxxxx seconds.
--------------------------------------------------------------------------------------
2 tests, 16 assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
100% passed
--------------------------------------------------------------------------------------
x.xx tests/s, x.xx assertions/s
```
  
  
Command
-------

You can run the [script](https://github.com/AstinCHOI/NetStorageKit-Ruby/blob/master/cms_netstorage.rb) with command line parameters.

```bash
$ ruby cms_netstorage.rb -H astin-nsu.akamaihd.net -k astinapi -K xxxxxxxxxx -a dir /407617
```
  
Use -h or --help option for more detail.
  
  
Author
------

Astin Choi (achoi@akamai.com)  
  
  
License
-------

Copyright 2018 Akamai Technologies, Inc.  All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.