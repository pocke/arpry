module Arpry
  class CLI
    def initialize(argv)
      @argv = argv
      @database = nil
      @adapter = nil
    end

    def run
      parse_options

      namespace = ClassFactory.create(@params)
      binding.pry(namespace)

      return 0
    end

    private

    def parse_options
      opt = OptionParser.new
      opt.on('-a [NAME]', '--adapter [NAME]')
      opt.on('-h [HOST]', '--host [HOST]')
      opt.on('-u [NAME]', '--username [NAME]')
      opt.on('-p [PASSOWRD]', '--password [PASSOWRD]')
      opt.on('-d [DB]', '--database [DB]')
      @params = {}
      args = opt.parse(@argv, into: @params)

      @params[:database] ||= args[0]
      if File.exist?(@params[:database])
        @params[:adapter] ||= 'sqlite3'
      end
    end
  end
end
