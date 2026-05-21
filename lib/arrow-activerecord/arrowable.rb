require 'arrow'

module ArrowActiveRecord
  module Arrowable
    def to_arrow(batch_size: 10000)
      record_batches = each_record_batch(batch_size:).to_a
      Arrow::Table.new(record_batches.first.schema, record_batches)
    end

    def each_record_batch(batch_size: 10000, &block)
      return to_enum(__method__, batch_size:) unless block_given?

      schema = build_arrow_schema
      target_column_names = schema.fields.collect(&:name)
      record_batch_builder = Arrow::RecordBatchBuilder.new(schema)
      in_batches(of: batch_size).each do |relation|
        records = relation.pluck(*target_column_names)
        if target_column_names.size == 1
          # [1, 2, 3] ->
          # [[1], [2], [3]]
          record_batch_builder.append(records.collect {|value| [value]})
        else
          record_batch_builder.append(records)
        end
        yield(record_batch_builder.flush)
      end
    end

    private
    def build_arrow_schema
      target_column_names = select_values
      target_column_names = column_names if select_values.empty?

      fields = []
      target_column_names.each do |name|
        name = name.to_s
        target_column = columns.find do |column|
          column.name == name
        end
        fields << {name: name, data_type: extract_arrow_data_type(target_column)}
      end
      Arrow::Schema.new(fields)
    end

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
        :int64
      when :binary
        :binary
      when :boolean
        :boolean
      when :date
        :date32
      when :datetime
        [:timestamp, :nano]
      when :decimal
        [:decimal128, type.precision, type.scale]
      when :float
        :float
      when :integer
        :int32
      # when :json
      when :string, :text
        :string
      when :time, :timestamp
        [:timestamp, :nano]
      else
        message = "unsupported data type: #{type}: #{column.inspect}"
        raise NotImplementedError, message
      end
    end
  end
end
