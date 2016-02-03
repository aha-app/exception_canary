module ExceptionCanary
  class Group < ActiveRecord::Base
    has_many :stored_exceptions

    validates :name, presence: true
    validates :action, presence: true
    validates :match_type, presence: true
    validates :value, presence: true
    validate :note_if_suppressing

    attr_accessible :name, :action, :match_type, :value, :note, :is_auto_generated

    calculated :exceptions_count, -> { 'select count(*) from exception_canary_stored_exceptions where exception_canary_stored_exceptions.group_id = exception_canary_groups.id' }
    calculated :most_recent_exception, -> { 'select max(created_at) from exception_canary_stored_exceptions where exception_canary_stored_exceptions.group_id = exception_canary_groups.id' }

    ACTION_NOTIFY   = 10
    ACTION_SUPPRESS = 20
    ACTIONS = [ACTION_NOTIFY, ACTION_SUPPRESS]

    MATCH_TYPE_EXACT = 10
    MATCH_TYPE_REGEX = 20
    MATCH_TYPES = [MATCH_TYPE_EXACT, MATCH_TYPE_REGEX]

    def self.find_group_for_exception(se)
      self.where(title: se.title).first || self.where(match_type: MATCH_TYPE_REGEX).find { |r| r.matches?(se) }
    end

    def self.create_new_group_for_exception(se)
      self.create!(name: se.short_title, action: ACTION_NOTIFY, match_type: MATCH_TYPE_EXACT, value: se.title)
    end

    def notify?
      action == ACTION_NOTIFY
    end

    def suppress?
      action == ACTION_SUPPRESS
    end

    def exact?
      match_type == MATCH_TYPE_EXACT
    end

    def short_value
      lines = value.split("\n").first
    end

    def auto_generated?
      is_auto_generated
    end

    def matches?(exception)
      case match_type
      when MATCH_TYPE_EXACT
        exception.title == value
      when MATCH_TYPE_REGEX
        !Regexp.new(value).match(exception.title).nil?
      end
    end

    private

    def note_if_suppressing
      errors.add(:note, 'must be populated when suppressing notifications.') if suppress? && note.blank?
    end
  end
end
