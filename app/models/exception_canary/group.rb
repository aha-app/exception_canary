module ExceptionCanary
  class Group < ActiveRecord::Base
    has_many :stored_exceptions, order: :created_at

    validates :name, presence: true
    validates :fingerprint, presence: true
    validates :notification_action, presence: true

    attr_accessible :name, :fingerprint, :notification_action

    scope :search, -> (term) { where('name ILIKE ?', "%#{term}%") }
    
    calculated :exceptions_count, -> { 'select count(*) from exception_canary_stored_exceptions where exception_canary_stored_exceptions.group_id = exception_canary_groups.id' }
    calculated :most_recent_exception, -> { 'select max(created_at) from exception_canary_stored_exceptions where exception_canary_stored_exceptions.group_id = exception_canary_groups.id' }

    NOTIFICATION_IMMEDIATE = 0
    NOTIFICATION_DIGEST = 10
    NOTIFICATION_SUPPRESS = 100

    after_initialize :set_defaults
    
    def set_defaults
      self.notification_action ||= NOTIFICATION_IMMEDIATE
    end

    def self.find_group_for_exception(se)
      self.where(fingerprint: se.fingerprint).first
    end

    def self.create_new_group_for_exception(se)
      self.create!(name: se.title, action: ACTION_NOTIFY, fingerprint: se.fingerprint)
    end

    def notify?
      notification_action != NOTIFICATION_SUPPRESS
    end

    def suppress?
      notification_action == NOTIFICATION_SUPPRESS
    end
    
    def self.delete_unused_groups!
      Group.where("not exists (select 'x' from exception_canary_stored_exceptions where exception_canary_stored_exceptions.group_id = exception_canary_groups.id)").destroy_all
    end
  end
end
