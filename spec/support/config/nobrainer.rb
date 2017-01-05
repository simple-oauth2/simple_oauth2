ENV['DB_HOST'] ||= 'localhost'

NoBrainer::Document::PrimaryKey.__send__(:remove_const, :DEFAULT_PK_NAME)
NoBrainer::Document::PrimaryKey.__send__(:const_set,    :DEFAULT_PK_NAME, :_id_)

db_name = "#{ENV['ORM']}_#{ENV['RAILS_ENV']}"
NOBRAINER_CONF = proc do |c|
  c.reset!
  c.rethinkdb_url = "rethinkdb://#{ENV['DB_HOST']}/#{db_name}"
  c.environment = ENV['RAILS_ENV']
end
