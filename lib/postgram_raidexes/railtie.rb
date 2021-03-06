module PostgramRaidexes
  class Railtie < Rails::Railtie
    initializer "postgram_raidexes.postgresql_overrides" do
      break unless using_postgresql?

      raise "Only Rails 4 is supported at this time" unless Rails::VERSION::MAJOR == 4

      case Rails::VERSION::MINOR
      when 1
        require "postgram_raidexes/pg_opclass_support_rails_41"
      when 2
        require "postgram_raidexes/pg_opclass_support_rails_42"
      end
    end

    def using_postgresql?
      ActiveRecord::Base.configurations[Rails.env]['adapter'].casecmp('postgresql').zero?
    end
  end
end