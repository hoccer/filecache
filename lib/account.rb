module Hoccer
  class Account
    include Mongoid::Document
    field :websites, :type => Array, :default => Array.new
    
    store_in :accounts
  end
end
