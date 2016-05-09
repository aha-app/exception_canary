module ExceptionCanary
  module ApplicationHelper
    def format_time(time)
      time = Time.parse(time) if time.is_a? String
      time.strftime('%Y-%m-%d %H:%M:%S')
    end
    
    def format_time_ago(time)
      distance = (Time.now.utc - time).round
      distance_in_minutes = (distance / 60.0).round
      s = case distance_in_minutes
        when 0..1
          "#{distance} secs"
        when 2..59
          "#{distance_in_minutes} mins"
        when 60..(23*60)
          "#{(distance_in_minutes/60.0).round} hours"
        else
          "#{(distance_in_minutes/(24*60.0)).round} days"
        end
      "<span title='#{format_time(time)}'>#{s}</span>".html_safe
    end
    
    def group_id(id)
      "##{id.to_s[-5..-1]}"
    end
    
  end
end
