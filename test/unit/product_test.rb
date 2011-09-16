require 'test_helper'
#the default for rails is to load all fixtures
#fixtures :products

class ProductTest < ActiveSupport::TestCase
  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end
  
  test "product price must be positive" do
    product = Product.new(:title => "My Book Title",
                          :description => "yyy",
                          :image_url => "zzz.jpg")
    product.price = -1
    assert product.invalid?
    assert_equal "must be greater than or equal to 0.01",
      product.errors[:price].join('; ')

    product.price = 0
    assert product.invalid?
    assert_equal "must be greater than or equal to 0.01",
      product.errors[:price].join('; ')

    product.price = 1
    assert product.valid?
  end
  
  def new_product(image_url)
    Product.new(:title        => "My Book Title",
                :description  => "yyy",
                :price        => 1,
                :image_url    => image_url)
  end
  
  # TODO: use optional method arguments to merge new_product_with_title and new_product
  def new_product_with_title(title)
    Product.new(:title        => title,
                :description  => products(:ruby).description,
                :price        => products(:ruby).price,
                :image_url    => products(:ruby).image_url)
  end
  
  test "image url" do
    ok = %w{ fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg
      http://a.b.c/x/y/z/fred.gif }
    bad = %w{ fred.doc fred.gif/more fred.gif.more }
    
    ok.each do |name|
      assert new_product(name).valid?, "#{name} shouldn't be invalid"
    end
    
    bad.each do |name|
      assert new_product(name).invalid?, "#{name} shouldn't be valid"
    end
  end
  
  test "product is not valid without a unique title" do
    product = Product.new(:title       => products(:ruby).title,
                          :description => "yyy",
                          :price       => 1,
                          :image_url   => "fred.gif")
                          
    assert !product.save
    assert_equal I18n.translate('activerecord.errors.messages.taken'),
      product.errors[:title].join('; ')
  end
  
  test "product title must be at least 10 characters" do
    good_titles = %w{ 1234567890 }
    bad_titles = %w{ 1 123456789 }

    good_titles.each do |title|
      assert new_product_with_title(title).valid?, "#{title} shouldn't be invalid"
    end
    
    bad_titles.each do |title|
      assert new_product_with_title(title).invalid?, "#{title} shouldn't be valid"
    end
    
    #assert !product.save
    #assert_equal I18n.translate('activerecord.errors.messages.short'),
    #  product.errors[:title].join('; ')
  end
end
