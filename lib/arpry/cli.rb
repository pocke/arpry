module Arpry
  class CLI
    def initialize(argv)
      @argv = argv
      @database = nil
      @adapter = nil
    end

    def run
      parse_options

      ApplicationRecord.establish_connection(@params)

      generate_classes

      binding.pry(Namespace)

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

    def generate_classes
      classes = ApplicationRecord.connection.tables.map do |table|
        Namespace.const_set(table.classify, Class.new(ApplicationRecord) do
          self.table_name = table
        end)
      end

      relations = Array.new(classes.size) do
        Array.new(classes.size)
      end

      classes.each.with_index do |klass, idx|
        klass.columns.each do |col|
          ref_name = col.name[/\A(.+)(_id|ID)\z/, 1]
          next unless ref_name
          ref_klass_idx = classes.find_index {|c| c.table_name == ref_name.singularize || c.table_name == ref_name.pluralize}
          next unless ref_klass_idx

          relations[idx][ref_klass_idx] = col.name
        end
      end

      relations.each.with_index do |row, idx|
        klass = classes[idx]
        exists = row.map.with_index.select {|fk, _idx| fk}

        exists.each do |fk, ref_klass_idx|
          next unless fk

          ref_klass = classes[ref_klass_idx]

          klass.belongs_to ref_klass.table_name.singularize.to_sym, foreign_key: fk
          ref_klass.has_many klass.table_name.pluralize.to_sym, foreign_key: fk
        end

        # from -> klass <- to
        exists.permutation(2).each do |from, to|
          from_klass = classes[from[1]]
          to_fk = to[0]
          to_klass = classes[to[1]]
          from_klass.has_many to_klass.table_name.pluralize.to_sym, foreign_key: to_fk, through: klass.table_name.pluralize.to_sym
        end
      end
    end
  end
end
