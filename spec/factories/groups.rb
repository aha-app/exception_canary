FactoryGirl.define do
  factory :group, class: ExceptionCanary::Group do
    name 'Some Group'
    action ExceptionCanary::Group::NOTIFICATION_IMMEDIATE
  end
end
