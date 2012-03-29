class Ad < ActiveRecord::Base
#attr_accessible :section_id, :category_id
  attr_writer :current_step
  belongs_to :section
  belongs_to :user
  belongs_to :category
  belongs_to :sub_category , :class_name => "Category", :foreign_key => :sub_category_id

  extend FriendlyId
  friendly_id :title, :use => :slugged

  acts_as_gmappable :validation => lambda { |u| u.current_step == "find_on_map" }

  has_many :images, :as => :assetable, :class_name => "Ad::Image", :dependent => :destroy

  accepts_nested_attributes_for :images

  
  NUMBER = ['1','2','3','4','5','6','7','8','9','10','11','12+']
  
  WORK_EXPERIENCE = {"UN" => "Unspecified",
"00" => "0-1 Years" ,
"01" => "1-2 Years",
"02" => "2-5 Years",
"05" => "5-10 Years",
"10" => "10-15 Years",
"15" => "15+ Years"}

  EDUCATION_LEVEL = {"UN" => "Unspecified",
"HS"=>"High-School / Secondary School",
"BD"=>"Bachelors Degree",
"MD"=>"Masters Degree",
"PH" =>"PhD"
  }




  validates :section_id,:category_id, :presence => true , :if => lambda { |o| o.current_step == "categories" }
  validates :section_id,:category_id, :presence => true , :if => lambda { |o| o.current_step == "categories" }
  validates :title , :size , :fee ,:bed_rooms, :bath_rooms , :developer ,:ready_date, :annual_comm_fee, :amenities, :presence => true , :if => lambda { |o| o.current_step == "details"  && o.section_id != 4 }
  validates :title , :compensation, :work_experience ,:education_level, :commitment , :desc, :presence => true , :if => lambda { |o| o.current_step == "details"  && o.section_id == 4 }
  validates :street , :city, :country, :presence => true , :if => lambda { |o| o.current_step == "find_on_map" }



  scope :category_ads, lambda {|sec_id,cat_id|
    where("ads.section_id = ? && ads.category_id = ?", sec_id ,cat_id)
  }
  

#  searchable do
#    text :title
#  end

  def gmaps4rails_address
#describe how to retrieve the address from your model, if you use directly a db column, you can dry your code, see wiki
  "#{self.street}, #{self.city}, #{self.country}"
  end
  def gmaps4rails_infowindow
      # add here whatever html content you desire, it will be displayed when users clicks on the marker
     "#{self.street}, #{self.city}, #{self.country}"
  end
  def current_step
    @current_step || steps.first
  end
  
  def steps
    %w[categories agree_to_terms details find_on_map images]
  end

  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end

  def previous_step
    self.current_step = steps[steps.index(current_step)-1]
  end

  def first_step?
    current_step == steps.first
  end

  def last_step?
    current_step == steps.last
  end

  def all_valid?
    steps.all? do |step|
      self.current_step = step
      valid?
    end
  end
  def published?
    false
  end

end
