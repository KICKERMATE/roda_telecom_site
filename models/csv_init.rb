# frozen_string_literal: true

require 'csv'

# class of Calling Plan of the telecom company
module CSVInit
  # get subs_list from csv
  def self.get_subs_list(filepath, plans_list)
    subs = []
    CSV.foreach(filepath, 'r', encoding: 'UTF-8') do |row|
      subs.append(Sub.new(row[0],
                          row[1],
                          row[2].to_i,
                          plans_list.plan_by_name(row[3]),
                          row[4].to_i))
    end
    SubList.new(subs)
  end

  # plans from csv
  def self.get_plans_list(filepath)
    plans = []
    CSV.foreach(filepath, 'r', encoding: 'UTF-8') do |row|
      plans.append(CallingPlan.new(row[0],
                                   (row[1] != 'inf' ? row[1].to_f : 'inf'),
                                   row[2].to_f,
                                   row[3].to_f))
    end
    CallingPlanList.new(plans)
  end
end
