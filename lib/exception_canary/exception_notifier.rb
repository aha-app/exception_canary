class ExceptionNotifier
  class Notifier < ActionMailer::Base
    def exception_notification(env, exception, options = {})
      options.update(env: env)
      e = ExceptionCanary.create_ruby_exception!(exception, options)
      return false if ExceptionCanary.suppress_exception?(e)

      prepend_view_path "#{Gem.loaded_specs['exception_canary'].full_gem_path}/app/views"

      load_custom_views

      @env        = env
      @se         = e
      @exception  = exception
      @options    = options.reverse_merge(env['exception_notifier.options'] || {}).reverse_merge(self.class.default_options)
      @kontroller = env['action_controller.instance'] || MissingController.new
      @request    = ActionDispatch::Request.new(env)
      @backtrace  = exception.backtrace ? clean_backtrace(exception) : []
      @sections   = @options[:sections]
      @data       = (env['exception_notifier.exception_data'] || {}).merge(options[:data] || {})
      @sections += %w(data) unless @data.empty?

      compose_email
    end

    def background_exception_notification(exception, options = {})
      options.update(env: {})
      e = ExceptionCanary.create_ruby_exception!(exception, options)
      return false if ExceptionCanary.suppress_exception?(e)

      prepend_view_path "#{Gem.loaded_specs['exception_canary'].full_gem_path}/app/views"

      load_custom_views

      if @notifier = Rails.application.config.middleware.detect { |x| x.klass == ExceptionNotifier }
        @options   = options.reverse_merge(@notifier.args.first || {}).reverse_merge(self.class.default_options)
        @exception = exception
        @se        = e
        @backtrace = exception.backtrace || []
        @sections  = @options[:background_sections]
        @data      = options[:data] || {}

        compose_email
      end
    end
  end
end
