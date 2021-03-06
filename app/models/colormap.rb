class Colormap < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged
  has_many :histories, :dependent => :destroy

  validates_presence_of :uri
  validates_numericality_of :color_count, :greater_than => 0
  serialize :treemap

  before_validation :get_attrs
  after_save :add_history

  def name
    self.uri[/([\w]+).[\w\/]+$/,1].capitalize
  end

  private

  def get_attrs
    @site = DryCss::Site.new(uri)
    @css = DryCss::CSS.new(*@site.uris)
    self.color_count = @css.colors[:counts].count
    self.reference_count = @css.colors[:total]
    self.treemap = {:name => '', :children => []}
    @css.colors[:counts].map{|k,v| self.treemap[:children].push({'name' => k[-1,1] == ';' ? k[0, k.size-1] : k, 'size' => v})}
  end

  def add_history
    self.histories.create(color_count: self.color_count, reference_count: self.reference_count)
  end

end
