NetstorageAPI: Akamai Netstorage API for Ruby
===============================================

[![Gem Version](https://badge.fury.io/rb/netstorageapi.svg)](https://badge.fury.io/rb/netstorageapi)

NetstorageAPI is Akamai Netstorage (File/Object Store) API for Ruby 2.0+.


Installation
------------

To install Netstorage API for Ruby:  

.. code-block:: bash

    $ gem install netstorageapi


Example
-------

.. code-block:: ruby

    irb> require "akamai/netstorage"
    irb>
    irb> NS_HOSTNAME = "astin-nsu.akamaihd.net"
    irb> NS_KEYNAME = "astinastin"
    irb> NS_KEY = "xxxxxxxxxx" # Don't expose NS_KEY on public repository.
    irb> NS_CPCODE = "360949"
    irb>
    irb> ns = Akamai::Netstorage.new(NS_HOSTNAME, NS_KEYNAME, NS_KEY)
    irb> local_source = "hello.txt"
    irb> netstorage_destination = "/#{NS_CPCODE}/hello.txt" # or "/#{NS_CPCODE}/" is same.
    irb>
    irb> ok, response = ns.upload(local_source, netstorage_destination)
    => [true, <#Net::HTTPOK 200 OK readbody=true>] # true means 200 OK; If false, it's not 200 OK 
    irb> response.body
    => "<HTML>Request Processed</HTML>\n"
    irb>


Methods
-------

.. code-block:: ruby

    irb> ns.delete(NETSTORAGE_PATH)
    irb> ns.dir(NETSTORAGE_PATH)
    irb> ns.download(NETSTORAGE_SOURCE, LOCAL_DESTINATION)
    irb> ns.du(NETSTORAGE_PATH)
    irb> ns.list(NETSTORAGE_PATH)
    irb> ns.mkdir(NETSTORAGE_PATH + DIRECTORY_NAME)
    irb> ns.mtime(NETSTORAGE_PATH, TIME) # ex) TIME: Time.now.to_i
    irb> ns.quick_delete(NETSTORAGE_DIR) # needs to be enabled on the CP Code
    irb> ns.rmdir(NETSTORAGE_DIR) # remove empty direcoty
    irb> ns.stat(NETSTORAGE_PATH)
    irb> ns.symlink(NETSTORAGE_SOURCE, NETSTORAGE_TARGET)
    irb> ns.upload(LOCAL_SOURCE, NETSTORAGE_DESTINATION)
    irb>
    irb>
    irb> # INFO: return (true/false, Net::HTTP.. Object)
    irb> #               true means 200 OK.
    irb> # INFO: can "upload" Only a single file, not directory.
    irb> # WARN: can raise FILE related error in "download" and "upload".
    irb>


Test
----

You can test all above methods with `unittest script <https://github.com/AstinCHOI/NetStorageKit-Ruby/blob/master/test_netstorage.rb>`_
(NOTE: You should input NS_HOSTNAME, NS_KEYNAME, NS_KEY and NS_CPCODE in the script):

.. code-block:: bash

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
    [TEST] rmdir /360949/1abb7a86-d7a1-4f8e-ac8e-77c867b1dfd7 done.
    [TEARDOWN] remove bf9fd3d4-1dd5-408c-873b-afc765ed05b9.txt from local done
    [TEARDOWN] remove bf9fd3d4-1dd5-408c-873b-afc765ed05b9.txt_rename from local done
    .

    Finished in 5.991238 seconds.
    --------------------------------------------------------------------------------
    1 tests, 14 assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
    100% passed
    --------------------------------------------------------------------------------
    0.17 tests/s, 2.34 assertions/s


Author
------

Astin Choi (achoi@akamai.com)  


License
-------

Copyright 2016 Akamai Technologies, Inc.  All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at `<http://www.apache.org/licenses/LICENSE-2.0>`_.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
