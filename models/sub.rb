# frozen_string_literal: true

# class of the telecom company calling plan subscriber
class Sub
  attr_reader :first_name, :last_name, :phone_number, :calling_plan, :minutes_in_past_month

  def initialize(first_name, last_name, phone_number, calling_plan, minutes_in_past_month)
    @first_name = first_name
    @last_name = last_name
    @phone_number = phone_number
    @calling_plan = calling_plan
    @minutes_in_past_month = minutes_in_past_month
  end

  def eql?(other)
    to_s == other.to_s
  end

  def bad_plan?
    true
  end

  def to_s
    "Подписчик: #{first_name} #{last_name}," \
      " Номер: #{phone_number}," \
      " План: #{calling_plan}," \
      " Использовал #{minutes_in_past_month} минут за последний месяц"
  end

  def small_info
    "#{first_name} #{last_name} (#{phone_number}). План: #{calling_plan}"
  end
end
