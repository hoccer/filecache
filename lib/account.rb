module Hoccer
  class Account
    include Mongoid::Document

    store_in :accounts
  end
end
