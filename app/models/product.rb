class Product < ActiveRecord::Base
  default_scope :order => 'title'
  
  validates :title, :description, :image_url, :presence => true
  validates :title, :uniqueness => true
  validates :title, :length => { :minimum => 10 }
  validates :price, :numericality => { :greater_than_or_equal_to => 0.01 }

  validates :image_url, :format => {
    :with   => %r{\.(gif|jpg|png)$}i, # '$' => End of Line
    :message => 'must be a URL for GIF, JPG or PNG image.'
  }
  
  has_many :line_items
  has_many :orders, :through => :line_items
  
  before_destroy :ensure_not_referenced_by_any_line_item
  
  private
  
    # ensure that there are no line items referencing this product
    def ensure_not_referenced_by_any_line_item
      if line_items.empty?
        return true
      else
        errors.add(:base, 'Line Items present')
        return false
      end
    end
end
