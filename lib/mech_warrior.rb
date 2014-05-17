require 'mechanize'
require 'xml-sitemap'
require 'logger'
require 'celluloid/autostart'
require_relative 'mech_warrior/mech_cell'
require_relative 'mech_warrior/crawler'

module MechWarrior
  SITEMAP_MAX_LINKS = 50000
  DEFAULTS = {
    allowed_domains:    [],
    default_protocol:   'http://',
    default_host:       'www.example.com',
    # this is less 'default_host' at the moment than 'only', though links to other domains will work as long
    # as all links on other domains' pages are absolute.  To support multiple domains while supporting
    # relative links, some new state would have to be introduced to track 'current_host'
    max_depth_divisor:  256, # this results in max depth of 4096 on my machine, seems deep enough
    pool_size:          20,
    logger_class:       Logger,
    log_file_name:      "mech_warrior_errors.txt"
  }

  def self.crawl(opts={})
    crawl_results = Crawler.new(opts)
    crawl_results.agent_pool.future.terminate
    unless opts[:skip_asset_json]
      File.open("#{crawl_results.default_host}_crawl_#{Time.now.gmtime}", 'w') do |file|
        file.write(JSON.pretty_generate(crawl_results.pages))
      end
    end

    if sitemap_opts = opts[:generate_sitemap]
      generate_sitemap(crawl_results.default_host,
                      crawl_results.pages,
                      sitemap_opts.respond_to?(:keys) ? sitemap_opts : {}
                      )
    end

    crawl_results
  end


  #generate_sitemap is untested and NOT production ready, but is functional
  #and probably a better output format if asset/link data is not needed
  def self.generate_sitemap(default_host, pages, opts, sitemap_file_num=1)
    page_keys = pages.keys
    current_page_keys = page_keys.slice(0...SITEMAP_MAX_LINKS)

    site_map = XmlSitemap::Map.new(default_host) do |map|
      current_page_keys.each do |page|
        map.add URI(page).path, opts if URI(page).path.length > 0
      end
    end
    site_map.render_to("./site_map_#{default_host}_#{sitemap_file_num}")

    if page_keys.count > SITEMAP_MAX_LINKS
      generate_sitemap(default_host, page_keys.slice(SITEMAP_MAX_LINKS..-1), opts, sitemap_file_num + 1)
    end
  end
end
