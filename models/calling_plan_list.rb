# frozen_string_literal: true

require 'forwardable'

# list of subscribers
class CallingPlanList
  extend Forwardable
  def_delegator :@plans, :each, :each
  def_delegator :@plans, :empty?, :empty?

  def initialize(plans = [])
    @plans = plans
  end

  def add_plan(plan)
    @plans.append(plan)
  end

  # get CallingPlan by it's name field
  def plan_by_name(name)
    @plans.each do |this_plan|
      return this_plan if this_plan.name == name
    end
  end

  # deletes by its object
  def delete_plan(plan_to_del)
    @plans.delete(plan_to_del) if @plans.include? plan_to_del
  end

  def all_plans
    @plans.dup
  end

  def all_plans_names
    @plans.map(&:name).uniq
  end

  def best_plan_for_sub(sub)
    return CallingPlan.new('', 0, 0, 0.0) if @plans.empty?

    result_plan = @plans[0]
    @plans.lazy.drop(1).each do |plan|
      price = plan.price_for_mins(sub.minutes_in_past_month)
      result_plan = plan if price < result_plan.price_for_mins(sub.minutes_in_past_month)
    end
    result_plan
  end
end
