require 'arrow'

module ArrowActiveRecord
  module Arrowable
    def to_arrow(batch_size: 10000)
      target_column_names = select_values
      target_column_names = column_names if select_values.empty?

      fields = []
      data_types = []
      target_column_names.each do |name|
        name = name.to_s
        target_column = columns.find do |column|
          column.name == name
        end
        arrow_data_type = extract_arrow_data_type(target_column)
        fields << Arrow::Field.new(name, arrow_data_type)
        data_types << arrow_data_type
      end
      schema = Arrow::Schema.new(fields)

      arrow_array_batches = data_types.collect do
        []
      end
      in_batches(of: batch_size).each do |relation|
        column_values_set = relation.pluck(*target_column_names).transpose
        data_types.each_with_index do |data_type, i|
          column_values = column_values_set[i]
          arrow_array_batches[i] << build_arrow_array(column_values, data_type)
        end
      end
      columns = fields.collect.with_index do |field, i|
        chunked_array = Arrow::ChunkedArray.new(arrow_array_batches[i])
        Arrow::Column.new(field, chunked_array)
      end

      Arrow::Table.new(schema, columns)
    end

    private
    def extract_arrow_data_type(column)
      type = nil
      if column
        if column.bigint?
          type = :bigint
        else
          type = column.type
        end
      end
      case type
      when :bigint
        Arrow::Int64DataType.new
      when :binary
        Arrow::BinaryDataType.new
      when :boolean
        Arrow::BooleanDataType.new
      when :date
        Arrow::Date32DataType.new
      when :datetime
        Arrow::TimestampDataType.new(:nano)
      # when :decimal
      when :float
        Arrow::FloatDataType.new
      when :integer
        Arrow::Int32DataType.new
      # when :json
      when :string, :text
        Arrow::StringDataType.new
      when :time, :timestamp
        Arrow::TimestampDataType.new(:nano)
      else
        message = "unsupported data type: #{type}: #{column.inspect}"
        raise NotImplementedError, message
      end
    end

    def build_arrow_array(column_values, data_type)
      case data_type
      when Arrow::Int64DataType
        Arrow::Int64Array.new(column_values)
      when Arrow::BinaryDataType
        Arrow::BinaryArray.new(column_values)
      when Arrow::BooleanDataType
        Arrow::BooleanArray.new(column_values)
      when Arrow::Date32DataType
        Arrow::Date32Array.new(column_values)
      when Arrow::TimestampDataType
        builder = Arrow::TimestampArrayBuilder.new(data_type)
        builder.build(column_values)
      when Arrow::FloatDataType
        Arrow::FloatArray.new(column_values)
      when Arrow::Int32DataType
        Arrow::Int32Array.new(column_values)
      when Arrow::StringDataType
        Arrow::StringArray.new(column_values)
      else
        message = "unsupported data type: #{data_type.inspect}"
        raise NotImplementedError, message
      end
    end
  end
end
