NetstorageAPI: Akamai Netstorage API for Ruby
===============================================

[![Gem Version](https://badge.fury.io/rb/netstorageapi.svg)](https://badge.fury.io/rb/netstorageapi)

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
> NS_HOSTNAME = "astin-nsu.akamaihd.net"
> NS_KEYNAME = "astinastin"
> NS_KEY = "xxxxxxxxxx" # Don't expose NS_KEY on public repository.
> NS_CPCODE = "360949"
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
> ns.dir(NETSTORAGE_PATH)
> ns.download(NETSTORAGE_SOURCE, LOCAL_DESTINATION)
> ns.du(NETSTORAGE_PATH)
> ns.list(NETSTORAGE_PATH)
> ns.mkdir("#{NETSTORAGE_PATH}/#{DIRECTORY_NAME}")
> ns.mtime(NETSTORAGE_PATH, TIME) # ex) TIME: Time.now.to_i
> ns.quick_delete(NETSTORAGE_DIR) # needs to the privilege on the CP Code
> ns.rename(NETSTORAGE_TARGET, NETSTORAGE_DESTINATION)
> ns.rmdir(NETSTORAGE_DIR) # remove empty direcoty
> ns.stat(NETSTORAGE_PATH)
> ns.symlink(NETSTORAGE_TARGET, NETSTORAGE_DESTINATION)
> ns.upload(LOCAL_SOURCE, NETSTORAGE_DESTINATION)
>  
> # INFO: return (true/false, Net::HTTP.. Object)
> #               true means 200 OK.
> # INFO: can "upload" Only a single file, not directory.
> # WARN: Can raise Akamai::NetstorageError from all methods.
```
  
  
Test
----

You can test all above methods with [unittest script](https://github.com/AstinCHOI/NetStorageKit-Ruby/blob/master/test_netstorage.rb)
(NOTE: You should input NS_HOSTNAME, NS_KEYNAME, NS_KEY and NS_CPCODE in the script):

```bash
$ ruby test_netstorage.rb
Loaded suite test_netstorage
Started
[TEST] dir /360949 done
[TEST] mkdir /360949/1abb7a86-d7a1-4f8e-ac8e-77c867b1dfd7 done
[TEST] upload bf9fd3d4-1dd5-408c-873b-afc765ed05b9.txt to /360949/1abb7a86-d7a1-4f8e-ac8e-77c867b1dfd7/bf9fd3d4-1dd5-408c-873b-afc765ed05b9.txt done
[TEST] du done
[TEST] mtime /360949/1abb7a86-d7a1-4f8e-ac8e-77c867b1dfd7/bf9fd3d4-1dd5-408c-873b-afc765ed05b9.txt to 1469863258 done
[TEST] stat done
[TEST] symlink /360949/1abb7a86-d7a1-4f8e-ac8e-77c867b1dfd7/bf9fd3d4-1dd5-408c-873b-afc765ed05b9.txt to /360949/1abb7a86-d7a1-4f8e-ac8e-77c867b1dfd7/bf9fd3d4-1dd5-408c-873b-afc765ed05b9.txt_lnk done
[TEST] rename /360949/1abb7a86-d7a1-4f8e-ac8e-77c867b1dfd7/bf9fd3d4-1dd5-408c-873b-afc765ed05b9.txt to /360949/1abb7a86-d7a1-4f8e-ac8e-77c867b1dfd7/bf9fd3d4-1dd5-408c-873b-afc765ed05b9.txt_rename done
[TEST] download /360949/1abb7a86-d7a1-4f8e-ac8e-77c867b1dfd7/bf9fd3d4-1dd5-408c-873b-afc765ed05b9.txt_rename done
[TEST] delete /360949/1abb7a86-d7a1-4f8e-ac8e-77c867b1dfd7/bf9fd3d4-1dd5-408c-873b-afc765ed05b9.txt_rename done
[TEST] delete /360949/1abb7a86-d7a1-4f8e-ac8e-77c867b1dfd7/bf9fd3d4-1dd5-408c-873b-afc765ed05b9.txt_lnk done
[TEST] rmdir /360949/1abb7a86-d7a1-4f8e-ac8e-77c867b1dfd7 done
[TEARDOWN] remove bf9fd3d4-1dd5-408c-873b-afc765ed05b9.txt from local done
[TEARDOWN] remove bf9fd3d4-1dd5-408c-873b-afc765ed05b9.txt_rename from local done
.
[TEST] Invalid ns path NetstorageError test done
[TEST] Invalid local path NetstorageError test done
[TEST] Download directory path NetstorageError test done
.

Finished in x.xxxxxx seconds.
--------------------------------------------------------------------------------
2 tests, 14 assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
100% passed
--------------------------------------------------------------------------------
x.xx tests/s, x.xx assertions/s
```
  
  
Command
-------

You can run the [script](https://github.com/AstinCHOI/NetStorageKit-Ruby/blob/master/cms_netstorage.rb) with command line parameters.

```bash
$ ruby cms_netstorage.rb -H astin-nsu.akamaihd.net -k astinastin -K xxxxxxxxxx -a dir /360949
```
  
Use -h or --help option for more detail.
  
  
Author
------

Astin Choi (achoi@akamai.com)  
  
  
License
-------

Copyright 2016 Akamai Technologies, Inc.  All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.