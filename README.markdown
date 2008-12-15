`cf_case_check`
===============
http://github.com/rsutphin/cf_case_check
    
Description
-----------

`cf_case_check` is a utility which walks a ColdFusion application's source and 
determines which references to other files will not work with a case-sensitive
filesystem.  Its intended audience is developers/sysadmins who are migrating
a CF application from Windows hosting to Linux or another UNIX.

Features
--------

* Resolves references of the following types:
  - `CF_`-style custom tags
  - `cfinclude`
  - `cfmodule` (both `template` and `name`)
  - `createObject` (for CFCs only)
* Prints report to stdout
* Allows for designation of custom tag & CFC search paths outside the 
  application root

Synopsis
--------

    myapp$ cf_case_check

For command-line options, do:

    $ cf_case_check --help

Requirements
------------

* Ruby 1.8.6 or later (may work with earlier, but not tested)

Install
-------

Follow the GitHub rubygems [setup directions](http://gems.github.com/), then

    $ sudo gem install rsutphin-cf_case_check

License
-------

(The MIT License)

Copyright (c) 2008 Rhett Sutphin

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
