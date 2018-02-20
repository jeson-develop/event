class GroupEvent < ActiveRecord::Base
  STATUSES = {
      deleted: 0,
      draft: 1,
      published: 2,
      completed: 3
  }

  attr_accessor :is_published

  validates :user_id , presence: true
  validates :name, presence: true
  validates :description , presence: true, :if => Proc.new{ |f| f.is_published? }
  validates :start_at , presence: true, :if => Proc.new{ |f| f.end_at.nil? || f.duration.nil? }
  validates :duration , presence: true, :if => Proc.new{ |f| f.start_at.nil? || f.end_at.nil? }
  validates :end_at , presence: true, :if => Proc.new{ |f| f.start_at.nil? || f.duration.nil? }
  validates :location , presence: true, :if => Proc.new{ |f| f.is_published? }

  validate :validate_time_slot

  before_save :set_event_dates

  def after_initialize
    self.status = STATUSES[:draft] if self.status.nil?
  end

  def set_event_dates
    if self.start_at && self.duration
      self.end_at = (self.start_at.to_date + self.duration.days)
    elsif self.end_at && self.duration
      self.start_at = (self.end_at.to_date - self.duration.days)
    elsif self.start_at && self.end_at
      self.duration = (self.end_at.to_date.mjd - self.start_at.to_date.mjd)
    end
  end

  def set_status
    if self.is_published == 'true' or self.is_published == true
      self.status = STATUSES[:published]
    end
    self.status = STATUSES[:draft] if self.status.nil?
  end

  def validate_time_slot
    if self.start_at && self.start_at.to_date < Time.now.to_date
      self.errors.add(:start_at,'should not be past date')
      return false
    end
    if self.duration && self.duration < 1
      self.errors.add(:duration,'should be greater than 1 day')
      return false
    end
    if self.end_at && self.end_at.to_date < Time.now.to_date
      self.errors.add(:start_at,'should not be past date')
      return false
    end
    if self.start_at && self.end_at && self.end_at.to_date <= self.start_at.to_date
      self.errors.add(:end_at,'should be greater than start_at')
      return false
    end
  end

  protected

  def is_published?
    return (self.status == STATUSES[:published])
  end
end
