class PaymentType < ActiveRecord::Base
  def self.names()
    type_names = []
    all.each do |type|
      type_names.insert(-1, type.name)
    end
    type_names
  end
end
