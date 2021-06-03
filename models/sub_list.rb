# frozen_string_literal: true

require 'forwardable'

# list of subscribers
class SubList
  extend Forwardable
  def_delegator :@subs, :each, :each
  def_delegator :@subs, :empty?, :empty?

  def initialize(subs = [])
    @subs = subs
  end

  def subs_by_plan(plan)
    @subs.select { |sub| sub.calling_plan == plan }
  end

  # get not gotten phone number. nil if all are gotten
  def new_phone_number
    return 100_000 if @subs.empty?

    @subs.map(&:phone_number).sort.each_slice(2) do |a, b|
      return (a.to_i + 1) if !b.nil? && (b.to_i - a.to_i) > 1
    end
    nil
  end

  def sub_by_phone_number(phone_number)
    @subs.each do |sub|
      return sub if sub.phone_number.to_s == phone_number.to_s
    end
    nil
  end

  def add_sub(sub)
    @subs.append(sub)
  end

  def delete_sub(sub)
    @subs.delete(sub)
  end

  def all_subs
    @subs.dup
  end

  def sort
    @subs.sort_by do |sub|
      [sub.calling_plan.name, sub.last_name]
    end
    self
  end

  def filter_phone_last_name(phone_number, last_name)
    @filtered_subs = @subs.select do |sub|
      next if !phone_number.nil? && sub.phone_number != phone_number
      next if !last_name.nil? && sub.last_name != last_name

      true
    end
    @filtered_subs.sort_by do |sub|
      [sub.calling_plan.name, sub.last_name]
    end
  end

  def average_minutes(subs_list)
    return 0 if subs_list.empty? || subs_list.nil?

    subs_list.reduce(0.0) { |sum, sub| sum + sub.minutes_in_past_month } / subs_list.size
  end

  def average_minutes_above(subs_list)
    return 0 if subs_list.empty? || subs_list.nil?

    mins_limit = subs_list[0].calling_plan.minutes_limit
    if mins_limit == 'inf'
      0
    else
      mins_over_list = subs_list.map do |sub|
        if sub.minutes_in_past_month > sub.calling_plan.minutes_limit
          sub.minutes_in_past_month - sub.calling_plan.minutes_limit # over plan
        else
          0 # under plan
        end
      end
      mins_over_list.sum(0.0) / mins_over_list.size
    end
  end

  def average_payment
    payment = @subs.reduce(0.0) do |sum, sub|
      if sub.calling_plan.minutes_limit == 'inf' || sub.calling_plan.minutes_limit >= sub.minutes_in_past_month # fits
        sum + sub.calling_plan.monthly_payment
      else
        sum +
          sub.calling_plan.monthly_payment +
          (sub.minutes_in_past_month - sub.calling_plan.minutes_limit) * sub.calling_plan.minute_above_plan_price
      end
    end
    payment / @subs.size
  end

  def stats(plans_list)
    # stats[:...] - info about all the subs
    # ((stats[:plans_stats])[plan.name])[:...] - info about each plan
    stats = {}
    stats[:subs_amount] = @subs.size # 1
    stats[:average_payment] = average_payment # 3
    # 2, 4, 5, 6, ...
    stats[:plans_stats] = {}
    plans_list.each do |plan|
      subs_on_plan_list = @subs.select { |sub| sub.calling_plan == plan }
      (stats[:plans_stats])[plan.name] = {}
      ((stats[:plans_stats])[plan.name])[:subs_on_plan] = subs_on_plan_list.count
      ((stats[:plans_stats])[plan.name])[:average_minutes] = average_minutes(subs_on_plan_list)
      ((stats[:plans_stats])[plan.name])[:average_above_plan_minutes] = average_minutes_above(subs_on_plan_list)
    end
    stats
  end
end
