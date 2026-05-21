class ArrowableTest < Test::Unit::TestCase
  class Data < ActiveRecord::Base
  end

  setup do
    FileUtils.rm_rf(DB_PATH.dirname)
    FileUtils.mkdir_p(DB_PATH.dirname)
  end

  teardown do
    FileUtils.rm_rf(DB_PATH.dirname)
  end

  sub_test_case("#to_arrow") do
    setup do
      @date_value = Date.new(2018, 1, 10)
      @datetime_value = Time.iso8601("2018-01-10T18:05:01.1Z")
      @bigint_value = 2 ** 63 - 1
      ActiveRecord::Base.connection.create_table(:data) do |table|
        table.string :string_column
        table.date :date_column
        table.datetime :datetime_column
        table.boolean :boolean_column
        table.bigint :bigint_column
      end
      Data.create(string_column: "Hello",
                  date_column: @date_value,
                  datetime_column: @datetime_value,
                  boolean_column: false,
                  bigint_column: @bigint_value)
      Data.create(string_column: "Hello2",
                  date_column: @date_value + 1,
                  datetime_column: @datetime_value + 1,
                  boolean_column: true,
                  bigint_column: -@bigint_value - 1)
    end

    teardown do
      ActiveRecord::Base.connection.drop_table(:data)
    end

    test "one" do
      arrow = Data.all.select(:id).to_arrow
      assert_equal(<<-RECORD_BATCH, arrow.each_record_batch.first.to_s)
id:   [
    1,
    2
  ]
      RECORD_BATCH
    end

    test "all" do
      arrow = Data.all.to_arrow
      assert_equal(<<-RECORD_BATCH, arrow.each_record_batch.first.to_s)
id:   [
    1,
    2
  ]
string_column:   [
    "Hello",
    "Hello2"
  ]
date_column:   [
    #{@date_value},
    #{@date_value + 1}
  ]
datetime_column:   [
    #{@datetime_value.strftime("%Y-%m-%d %H:%M:%S.%9N")},
    #{(@datetime_value + 1).strftime("%Y-%m-%d %H:%M:%S.%9N")}
  ]
boolean_column:   [
    false,
    true
  ]
bigint_column:   [
    #{@bigint_value},
    #{-@bigint_value - 1}
  ]
      RECORD_BATCH
    end
  end
end
