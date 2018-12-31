module Arpry
  class CLI
    def initialize(argv)
      @argv = argv
      @database = nil
      @adapter = nil
    end

    def run
      parse_options

      ApplicationRecord.establish_connection(
        adapter: @adapter,
        database: @database,
      )

      generate_classes

      binding.pry(Namespace)

      return 0
    end

    private

    # TODO
    def parse_options
      @database = @argv[0]
      @adapter = 'sqlite3'
    end

    def generate_classes
      ApplicationRecord.connection.tables.each do |table|
        Namespace.const_set(table.classify, Class.new(ApplicationRecord) do
          self.table_name = table
        end)
      end
    end
  end
end
