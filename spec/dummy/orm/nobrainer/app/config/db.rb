NoBrainer::Document::PrimaryKey.__send__(:remove_const, :DEFAULT_PK_NAME)
NoBrainer::Document::PrimaryKey.__send__(:const_set,    :DEFAULT_PK_NAME, :_id_)

NoBrainer.configure do |config|
  config.reset!
  config.rethinkdb_url = "rethinkdb://localhost/#{"#{ENV['ORM']}_#{ENV['RAILS_ENV']}"}"
  config.environment = ENV['RAILS_ENV']
end
