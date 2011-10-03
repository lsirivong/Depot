require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  test "order_received" do
    mail = Notifier.order_received(orders(:one))
    assert_equal "Pragmatic Store Order Confirmation", mail.subject
    assert_equal ["dave@example.org"], mail.to
    assert_equal ["depot@example.com"], mail.from
    assert_match /1 x Programming Ruby 1.9/, mail.body.encoded
  end

  test "order_shipped" do
    mail = Notifier.order_shipped(orders(:one))
    assert_equal "Pragmatic Store Order Shipped", mail.subject
    assert_equal ["dave@example.org"], mail.to
    assert_equal ["depot@example.com"], mail.from
    assert_match /<td>1&times;<\/td>\s*<td>Programming Ruby 1.9<\/td>/,
      mail.body.encoded
  end
  
  test "error_occurred" do
    mail = Notifier.error_occurred("Error message")
    assert_equal "Admin Notification: Pragmatic Store Error Occurred", mail.subject
    assert_equal ["depot_admin@example.com"], mail.to
    assert_equal ["depot@example.com"], mail.from
    assert_match /Error message/, mail.body.encoded
  end

end
