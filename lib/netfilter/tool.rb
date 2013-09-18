class Netfilter
  class Tool
    attr_accessor :tables, :namespace

    def self.import(data)
      data = data.symbolize_keys
      new(data[:namespace]).tap do |tool|
        data[:tables].each do |data|
          tool.tables << Table.import(tool, data)
        end
      end
    end

    def self.executable
      name.demodulize.downcase
    end

    def self.execute(command)
      # puts "Executing: #{command}"
      stdout = `#{command} 2>&1`.strip
      status = $?
      if status.exitstatus == 0
        stdout
      else
        raise SystemError, :command => command, :error => stdout
      end
    end

    def initialize(namespace = nil)
      self.namespace = namespace
      self.tables = []
      yield(self) if block_given?
    end

    def table(name, &block)
      tables << Table.new(self, name, &block)
    end

    def pp
      tables.each do |table|
        puts [table.name]*"\t"
        table.chains.each do |chain|
          puts ["", chain.name_as_argument]*"\t"
          chain.filters.each do |filter|
            puts ["", "", filter]*"\t"
          end
        end
      end
    end

    def commands
      [].tap do |commands|
        tables.each do |table|
          table.commands.each do |command|
            commands << command.unshift(executable)*" "
          end
        end
      end
    end

    def up
      @executed_commands = []
      commands.each do |command|
        execute(command)
        @executed_commands << command
      end
    rescue SystemError => e
      rollback
      raise e
    end

    def down
      @executed_commands = commands
      rollback
    end

    def export
      {
        :namespace => namespace,
        :tables => tables.map{ |table| table.export },
      }
    end

    def executable
      self.class.executable
    end

    private

    def rollback
      @executed_commands.reverse.each do |command|
        command = argument_rename(command, "new-chain", "delete-chain")
        command = argument_rename(command, "append", "delete")
        command = argument_rename(command, "insert", "delete")
        execute(command)
      end
    end

    def argument_rename(command, old_name, new_name)
      command.gsub(/--#{Regexp.escape(old_name)}(\s|$)/, "--#{new_name}\\1")
    end

    def execute(command)
      self.class.execute(command)
    end
  end
end
