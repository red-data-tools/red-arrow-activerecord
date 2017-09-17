require 'arrow'

module ArrowActiveRecord
  module ActiveRecordExt
    def self.included(_)
      def to_arrow
        @target_column_names = self.select_values.size.zero? ? self.column_names : self.select_values
        schema = generate_schema
        records = generate_columns

        Arrow::RecordBatch.new(schema, self.size, records)
      end

      private

      def generate_schema
        fields = @target_column_names.map do |column_name|
          type = self.columns.find { |e| e.name == column_name.to_s }.type
          if type == :integer
            Arrow::Field.new(column_name,  :int64)
          elsif type == :float
            Arrow::Field.new(column_name,  :float)
          else
            Arrow::Field.new(column_name,  :string)
          end
        end

        Arrow::Schema.new(fields)
      end

      def generate_columns
        column_records = self.pluck(*@target_column_names).transpose

        @target_column_names.map.with_index do |column_name, idx|
          type = self.columns.find { |e| e.name == column_name.to_s }.type
          if type == :integer
            Arrow::UInt64Array.new(column_records[idx])
          elsif type == :float
            Arrow::FloatArray.new(column_records[idx])
          else
            Arrow::StringArray.new(column_records[idx])
          end
        end
      end
    end
  end
end
