module ExceptionCanary
  class StoredException < ActiveRecord::Base
    belongs_to :group

    paginates_per 50

    attr_accessible :message, :backtrace, :environment, :variables, :exception_class
    
    serialize :backtrace
    serialize :environment
    serialize :variables

    scope :search, -> (term) { where('title LIKE ?', "%#{term}%") }
    
    before_create :set_fingerprint
    
    def set_fingerprint
      self.fingerprint = compute_fingerprint
    end
    
    def compute_fingerprint
      bt = self.backtrace || []
      cleaned_backtrace = bt.collect do |line|
        [line[:f], line[:m]].join(":")
      end.join(":")
      
      fingerprint_data = [cleaned_backtrace, self.exception_class]
      
      Digest::SHA1.hexdigest(fingerprint_data.join(":"))
    end
    
    def backtrace_summary
      if backtrace.length < 300
        backtrace
      else
        "#{backtrace[0...297]}..."
      end
    end
    
    def title
      #title = "#{ENV['action_controller.instance']} #{title}" if ENV['action_controller.instance']
      controller = nil
      t = [controller, "(#{self.exception_class})", "\"#{self.short_title}\""].compact.join(" ")
    end
    
    def short_title
      message.split("\n").first
    end
    
    def self.sanitize_ruby_backtrace(bt)
      bt.collect do |line|
        file, line, method = line.split(":")
        method.gsub!(/(^in `)/, "").gsub!("'$")
        {f: file, l: line, m: method}
      end
    end
    
  end
end
