# oddb.org
* https://github.com/zdavatz/oddb.org

## Description
Open Drug Database for Switzerland. See the live version at http://ch.oddb.org

## Features/Problems
* Some email-Addresses are still hardcoded. That needs to be fixed and placed into etc/oddb.yml
* If you install oddb.org via gem please also see these [instructions](http://dev.ywesee.com/Niklaus/Index).

## Requirements
* `git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build`
* `rbenv install 3.1.0`
* `sudo apt-get install apache2 daemontools daemontools-run pkg-config libmagickwand-dev libpq-dev`
* `bzcat 22:00-postgresql_database-ch_oddb-backup.bz2 | su -c psql -l postgres -p 5433 ch_odd`
* see Guide.txt

## Useful commands
### Reparse compositions of 5 digit Swissmedic Numbers ([issue #139](https://github.com/zdavatz/oddb.org/issues/139))
`sudo -u apache bundle-300 exec ruby-300 jobs/import_swissmedic_only update_compositions 67685 60134`
### Reparse all compositions
`sudo -u apache bundle-300 exec ruby-300 jobs/import_swissmedic_only update_compositions`
### Check all packages
`sudo -u apache bundle-300 exec ruby-300 jobs/import_swissmedic_only check`

## Tests

* to run the Tests you need to do
  * bundle install
  * rake test
  * bundle exec rake spec/parslet_spec.rb # for parsing the compositions
  * look at the index.html in the coverage directory
  
* There are some Selenium/Watir based GUI integration tests. For details on how to use them have
  a look at tests_watir.textile. By default they are run using the gem headless (this can be overrriden by
  setting the environment variable ODDB_NO_HEADLESS)

* There is test/wrk_performance.lua allows a stress test with a typical load. See test/wrk_performance.lua for details on howto run it

## Local Documentation

* To build your local documentation do:
  * rdoc1.9 --op documentation

## Install

* sudo gem install oddb.org

## Developers

* [Zeno R.R. Davatz](https://www.linkedin.com/in/zdavatz/) 2002-present
* [Niklaus Giger](https://www.giger-electronique.ch/index.shtml) 2012-present
* [Masaomi Hatakeyama](http://www.fgcz.ch/the-center/people/hatakeyama.html) 2009-2011
* [Yasuhiro Asaka](https://www.linkedin.com/in/yasuhiro-asaka/) 2008-2009
* [Hannes Wyss](https://www.linkedin.com/in/hanneswyss/) 2002-2008

## French Translation Help

* [Herve Robin](https://www.linkedin.com/in/herobin/). Thank you Herve!

## License
### oddb.org
* GPLv3.0
### Dojo Toolkit
* Licensed under the [MIT license](http://www.opensource.org/licenses/mit-license.php)
** doc/resources/javascript/qrcode.js

## Trademarks
The word "QR Code" is registered trademark of [DENSO WAVE INCORPORATED](http://www.denso-wave.com/qrcode/faqpatent-e.html)

## Issues
For [Issues](https://github.com/zdavatz/oddb.org/issues) please open one on Github.
