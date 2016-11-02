class Feed < ApplicationRecord
  enum last_fetch_status: %w{not_yet_attempted ok not_modified error}.collect { |a| [a,a] }.to_h,  
    _prefix: 'last_fetch'
  # note that creates scopes Feed.last_fetch_error etc

  scope :last_fetch_success, -> { where(last_fetch_status: %w{ok not_modified}) }

  has_many :entries, dependent: :destroy

  validates_presence_of :feed_url

  def success?
    last_fetch_ok? || last_fetch_not_modified?
  end

  def mark_success(status = :ok)
    # no idea why self is needed here??
    self.last_fetch_at = Time.now
    self.last_fetch_status = status
  end

  def mark_failed(exception: nil)
    self.last_fetch_at = Time.now
    self.last_fetch_status = :error
    self.last_fetch_error_info = serialize_error_info(exception)
  end

  protected

  def serialize_error_info(exception)
    {
      class_name: exception.class.name,
      message: exception.message,
      backtrace: exception.backtrace
    }
  end

end