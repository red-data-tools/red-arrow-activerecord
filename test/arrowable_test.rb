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

  setup do
    @date_value = Date.new(2018, 1, 10)
    @datetime_value = Time.iso8601("2018-01-10T18:05:01.1Z")
    @max_bigint_value = 2 ** 63 - 1
    @min_bigint_value = -(2 ** 63)
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
                bigint_column: @max_bigint_value)
    Data.create(string_column: "Hello2",
                date_column: @date_value + 1,
                datetime_column: @datetime_value + 1,
                boolean_column: true,
                bigint_column: @min_bigint_value)
  end

  teardown do
    ActiveRecord::Base.connection.drop_table(:data)
  end

  sub_test_case("#to_arrow") do
    test "one column" do
      table = Data.all.select(:id).to_arrow(batch_size: 1)
      assert_equal([
                     Arrow::RecordBatch.new(id: Arrow::Int32Array.new([1])),
                     Arrow::RecordBatch.new(id: Arrow::Int32Array.new([2])),
                   ],
                   table.each_record_batch.to_a)
    end

    test "all columns" do
      table = Data.all.to_arrow(batch_size: 1)
      assert_equal([
                     Arrow::RecordBatch.new(
                       id: Arrow::Int32Array.new([1]),
                       string_column: Arrow::StringArray.new(["Hello"]),
                       date_column: Arrow::Date32Array.new([@date_value]),
                       datetime_column: Arrow::TimestampArray.new(
                         :nano,
                         [@datetime_value]
                       ),
                       boolean_column: Arrow::BooleanArray.new([false]),
                       bigint_column:
                         Arrow::Int64Array.new([@max_bigint_value]),
                     ),
                     Arrow::RecordBatch.new(
                       id: Arrow::Int32Array.new([2]),
                       string_column: Arrow::StringArray.new(["Hello2"]),
                       date_column: Arrow::Date32Array.new([@date_value + 1]),
                       datetime_column: Arrow::TimestampArray.new(
                         :nano,
                         [@datetime_value + 1],
                       ),
                       boolean_column: Arrow::BooleanArray.new([true]),
                       bigint_column:
                         Arrow::Int64Array.new([@min_bigint_value]),
                     ),
                   ],
                   table.each_record_batch.to_a)
    end
  end

  sub_test_case("#each_record_batch") do
    test "one column" do
      record_batches =
        Data.all.select(:id).each_record_batch(batch_size: 1).to_a
      assert_equal([
                     Arrow::RecordBatch.new(id: Arrow::Int32Array.new([1])),
                     Arrow::RecordBatch.new(id: Arrow::Int32Array.new([2])),
                   ],
                   record_batches)
    end

    test "all columns" do
      record_batches = Data.all.each_record_batch(batch_size: 1).to_a
      assert_equal([
                     Arrow::RecordBatch.new(
                       id: Arrow::Int32Array.new([1]),
                       string_column: Arrow::StringArray.new(["Hello"]),
                       date_column: Arrow::Date32Array.new([@date_value]),
                       datetime_column: Arrow::TimestampArray.new(
                         :nano,
                         [@datetime_value]
                       ),
                       boolean_column: Arrow::BooleanArray.new([false]),
                       bigint_column:
                         Arrow::Int64Array.new([@max_bigint_value]),
                     ),
                     Arrow::RecordBatch.new(
                       id: Arrow::Int32Array.new([2]),
                       string_column: Arrow::StringArray.new(["Hello2"]),
                       date_column: Arrow::Date32Array.new([@date_value + 1]),
                       datetime_column: Arrow::TimestampArray.new(
                         :nano,
                         [@datetime_value + 1],
                       ),
                       boolean_column: Arrow::BooleanArray.new([true]),
                       bigint_column:
                         Arrow::Int64Array.new([@min_bigint_value]),
                     ),
                   ],
                   record_batches)
    end
  end
end
