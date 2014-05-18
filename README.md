MechWarrior
=========

MechWarrior is a Mechanize and Celluloid powered site crawler that generates a
JSON file of all pages, links on pages, and assets those pages rely upon
as well as optionally generating an XML sitemap compliant with sitemaps 0.9
protocol.


Version
----

0.0.1

Tech
-----------

MechWarrior relies on several excellent RubyGems

* [Mechanize] - a ruby library that makes automated web interaction easy.
* [Celluloid] - an Actor-based concurrent object framework for Ruby
* [XML-Sitemap] - provides easy XML sitemap generation for Ruby/Rails/Merb/Sinatra applications


Installation
--------------

```sh
gem install mech_warrior
```

Crawling a site
---------------

```sh
bin/spider
```
and enter a host name, followed by any additional options you wish to pass in
to override default options in `lib/mech_warrior.rb`


Todo
----
Some of the functionality, including XML Sitemaps, is untested.
Support for multiple hosts in a single spider is currently incomplete,
despite the 'allowed_hosts' array, unless all but default host have
only absolute links to follow.

License
----

MIT

[mechanize]:https://github.com/sparklemotion/mechanize
[celluloid]:http://celluloid.io/
[xml-sitemap]:https://github.com/sosedoff/xml-sitemap


