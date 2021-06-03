# frozen_string_literal: true

# class of Calling Plan of the telecom company
class CallingPlan
  attr_reader :name, :minutes_limit, :monthly_payment, :minute_above_plan_price

  def initialize(name, minutes_limit, monthly_payment, minute_above_plan_price)
    @name = name.strip
    @minutes_limit = minutes_limit
    @monthly_payment = monthly_payment
    @minute_above_plan_price = minute_above_plan_price
  end

  def eql?(other)
    to_s == other.to_s
  end

  # get plan price for inputted minutes number
  def price_for_mins(mins)
    if @minutes_limit != 'inf' && (@minutes_limit < mins)
      @monthly_payment + (mins - @minutes_limit) * @minute_above_plan_price
    else
      @monthly_payment
    end
  end

  def to_s
    "План: #{@name}." \
    " Количетво минут: #{@minutes_limit}." \
    " Ежемесячная стоимость: #{@monthly_payment} руб." \
    " За минуту сверх плана: #{@minute_above_plan_price}"
  end
end
