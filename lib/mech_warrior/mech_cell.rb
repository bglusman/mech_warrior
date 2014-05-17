module MechWarrior
  class MechCell
    include Celluloid
    attr_reader :agent, :logger
    MECH_ERRORS = [
          SocketError,
          Mechanize::ResponseCodeError,
          Mechanize::ResponseReadError,
          Mechanize::UnsupportedSchemeError
        ]
    def initialize(logger)
      @agent = Mechanize.new
      @logger = logger
    end

    def get(url)
      agent.get(url)
    rescue *MECH_ERRORS => e
      logger << "Caught Exception getting URL: #{url} -- #{e}\n"
    end
  end
end