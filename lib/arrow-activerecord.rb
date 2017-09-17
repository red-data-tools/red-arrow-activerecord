require "arrow-activerecord/active_record_ext"

ActiveSupport.on_load :active_record do
  ActiveRecord::Relation.send :include, ArrowActiveRecord::ActiveRecordExt
end
