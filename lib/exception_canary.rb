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

    def create_ruby_exception!(exception, options)
      variables = {}
      variables[:env] = {}
      variables[:request] = {}
      variables[:data] = options[:data] || {}
      variables[:server] = {
        process: $$,
        server: `hostname`.chomp
      }
      
      if options[:env]
        request = ActionDispatch::Request.new(options[:env])
        variables[:request] = {
          url: request.url,
          ip_address: request.remote_ip,
          parameters: request.filtered_parameters.inspect,
          controller: inspect_object(options[:env]['action_controller.instance'])
        }
        request.filtered_env.each do |key, value|
          variables[:env][key] = inspect_object(value)
        end
      end
                  
      backtrace = ExceptionCanary::StoredException.sanitize_ruby_backtrace(exception.backtrace)

      stored_exception = ExceptionCanary::StoredException.new(
        message: exception.message,
        exception_class: exception.class.to_s,
        backtrace: backtrace, 
        variables: variables
      )
      stored_exception.regroup!
      stored_exception
    end

    def suppress_exception?(se)
      return true if ExceptionCanary.suppress_callback && ExceptionCanary.suppress_callback.call(se) == true
      se.group.suppress?
    end
    
    def inspect_object(object)
      case object
      when Hash, Array
        object.inspect
      when ActionController::Base
        "#{object.controller_name}##{object.action_name}"
      else
        object.to_s
      end
    end
  end
end
