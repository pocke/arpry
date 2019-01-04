module Arpry
  class ClassFactory
    def self.create(conn_option)
      self.new.run(conn_option)
    end

    def initialize
    end

    def run(conn_option)
      base = generate_base_class(conn_option)

      namespace = Module.new
      classes = generate_classes(base, namespace)
      define_foreign_keys(classes)

      namespace
    end

    private

    def generate_base_class(conn_option)
      # HACK: the base class must have a name.
      class_name = 'BaseClass' + SecureRandom.hex(20)
      Class.new(ActiveRecord::Base).tap do |klass|
        klass.logger = Arpry::Logger.logger
        self.class.const_set(class_name, klass)
        klass.establish_connection(conn_option)
      end
    end

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

    def generate_classes(base_class, namespace)
      base_class.connection.tables.map do |table|
        namespace.const_set(table.classify, Class.new(base_class) do
          self.table_name = table
        end)
      end
    end

    def define_foreign_keys(classes)
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

        klass.connection.foreign_keys(klass.table_name).each do |fk|
          ref_klass_idx = classes.find_index {|c| c.table_name == fk.to_table }
          next unless ref_klass_idx
          relations[idx][ref_klass_idx] = fk.options[:column]
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
