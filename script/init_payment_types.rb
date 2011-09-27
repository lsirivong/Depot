PaymentType.transaction do
  PaymentType.create(:name => 'Check*')
  PaymentType.create(:name => 'Credit Card*')
  PaymentType.create(:name => 'Purchase order*')
end