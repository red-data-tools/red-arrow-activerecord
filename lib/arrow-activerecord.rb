require "active_record"
require "arrow-activerecord/arrowable"

ActiveRecord::Relation.send :include, ArrowActiveRecord::Arrowable
