require "test-unit"

require "arrow-activerecord"

DB_PATH = Pathname(__dir__) + "db/test.sqlite3"
ActiveRecord::Base.configurations = {
  "test" => {
    "adapter" => "sqlite3",
    "database" => DB_PATH,
  }
}
ActiveRecord::Base.establish_connection(:test)
