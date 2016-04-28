require 'exception_notification'
require 'exception_notifier/rake'

require 'exception_canary/dashboard'
require 'exception_canary/exception_notifier'
require 'exception_canary/version'

module ExceptionCanary
  class << self
    attr_accessor :suppress_callback

    def root_url
      root =
        if Rails.application.config.respond_to?(:exception_canary_root)
          Rails.application.config.exception_canary_root
        else
          :exception_canary_url
        end

      if root.is_a? String
        root
      else
        host = Rails.application.config.action_mailer.default_url_options[:host]
        port = Rails.application.config.action_mailer.default_url_options[:port]
        Rails.application.routes.url_helpers.send(root, host: host, port: port)
      end
    end

    def create_exception!(exception, options)
      variables = {}
      unless options[:env].nil? || options[:env]['action_controller.instance'].nil?
        options[:env]['action_controller.instance'].instance_variables.each do |v|
          k = v.to_s
          variables[k] = options[:env]['action_controller.instance'].instance_variable_get(k) unless k.include? '@_'
        end
      end
      variables.merge!(env['exception_notifier.exception_data'] || {}) if options[:env]
      variables.merge!(options[:data]) if options[:data]
   
      title = "(#{exception.class}) \"#{exception.message}\""
      title = "#{ENV['action_controller.instance']} #{title}" if ENV['action_controller.instance']
      backtrace = exception.backtrace.join("\n") if exception.backtrace
      ExceptionCanary::StoredException.create! title: title, backtrace: backtrace, variables: variables, klass: exception.class.to_s
    end

    def suppress_exception?(se)
      return true if ExceptionCanary.suppress_callback && ExceptionCanary.suppress_callback.call(se) == true
      se.group = ExceptionCanary::Group.find_group_for_exception(se) || ExceptionCanary::Group.create_new_group_for_exception(se)
      se.save!
      se.group.suppress?
    end
  end
end
