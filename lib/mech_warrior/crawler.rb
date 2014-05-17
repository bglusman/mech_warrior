module MechWarrior
  class Crawler
    attr_reader :agent_pool, :pages, :opts, :default_host, :default_protocol, :logger, :output_file

    def initialize(override_opts={})
      @opts  = DEFAULTS.merge(override_opts)
      @default_host     = opts[:default_host]
      @default_protocol = opts[:default_protocol]
      opts[:allowed_domains] << default_host
      @output_file = opts[:output_file] || File.open(opts[:log_file_name], 'a')
      @logger = opts[:logger_class].new(output_file)
      @agent_pool = MechCell.pool(size: opts[:pool_size], args: [logger])
      @pages = {}
      start_url = opts[:start_url] || "#{default_protocol}#{default_host}/"
      pages[normalize_url(start_url)] = {}
      index_url(start_url) unless opts[:no_index]
      self
    ensure
      output_file.close if output_file.respond_to?(:close)
    end

    def index_url(href)
      schemed_url                 = normalize_url(href)
      future                      = page_future(schemed_url)
      process_page(future, schemed_url)
    end

    private

    def process_page(page_future, url, depth=0)
      return if depth > RubyVM::DEFAULT_PARAMS[:thread_vm_stack_size]/opts[:max_depth_divisor]
      page = page_future.value
      if page && page.respond_to?(:links)
        pages[url]          = {}
        pages[url][:links]  = page.respond_to?(:links) ? page.links.map(&:href) : []
        pages[url][:assets] = {
          images:       page.image_urls,
          scripts:      page.search('script'),
          asset_links:  page.search('link'), #css, icons
          iframes:      page.iframes
        }
        urls = links_to_follow(page).map {|link| normalize_url(link.href)}
        futures = urls.map {|url| page_future(url)}
        pairs = futures.zip(urls)
        pairs.each {|future, url| process_page(future, url, depth +1)}
      end
    rescue URI::InvalidURIError => e
      logger << "InvalidURIError processing links on page at URL: #{url} -- #{e}\n"
    end

    def page_future(url)
      agent_pool.future.get(url)
    end

    def get_page(url)
      agent_pool.get(url)
    end

    def normalize_url(href)
      URI(href).scheme ? href : "#{default_protocol}#{default_host}#{href}"
    end

    def follow_link?(link) #follow only pages not indexed and relative links or whitelisted link hosts
      if link.href && URI(link.href)
        pages[normalize_url(link.href)].nil? && (link.uri.host.nil? || opts[:allowed_domains].include?(link.uri.host))
      end
    rescue URI::InvalidURIError => e
      logger << "InvalidURIError on link with href: #{link.href} -- #{e}\n"
    end

    def links_to_follow(page)
      page.links.select { |link| follow_link?(link) }
    end
  end
end
