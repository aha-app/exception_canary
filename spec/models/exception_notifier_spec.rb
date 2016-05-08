require 'spec_helper'

describe ExceptionCanary do

  describe 'exception_notifier' do
    it 'creates exception' do
      begin
        raise "An exception"
      rescue Exception => e
        stored_exception = ExceptionCanary.create_ruby_exception!(e, {})
        Rails.logger.debug(stored_exception.inspect)
      end
    end
  end
end