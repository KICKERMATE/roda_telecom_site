# frozen_string_literal: true

require 'cgi'
require 'roda'
require_relative 'models'

# Main App class
# Suggested 1 subscriber can have more than 1 phone number
# !!!Suggested data files are correct!!!
class TelecomApp < Roda
  opts[:root] = __dir__
  plugin :environments
  plugin :render
  plugin :forme
  plugin :status_handler

  configure :development do
    plugin :public
    opts[:serve_static] = true
  end

  opts[:plans] = CSVInit.get_plans_list('data/calling_plans.csv')
  opts[:subs] = CSVInit.get_subs_list('data/subscribers.csv', opts[:plans])

  status_handler(404) do
    view('not_found')
  end

  route do |r|
    r.public if opts[:serve_static]

    r.root do
      r.redirect '/subscribers'
    end

    r.on 'plans' do
      r.on String do |plan_name|
        next unless opts[:plans].all_plans_names.index(CGI.unescape(plan_name))

        r.is do
          @this_plan = opts[:plans].plan_by_name(CGI.unescape(plan_name))
          @subs = opts[:subs].subs_by_plan(@this_plan)
          view('plan')
        end
      end
    end

    r.on 'subscribers' do
      r.is do
        next if opts[:plans].empty?

        @parameters = DryResultFormeWrapper.new(SubFilterSchema.call(r.params))
        @subs = if @parameters.success?
                  opts[:subs].filter_phone_last_name(@parameters[:phone_number], @parameters[:last_name])
                else
                  opts[:subs].sort
                end

        view('subscribers')
      end

      r.on 'stats' do
        @stats = opts[:subs].stats(opts[:plans])
        view('stats')
      end

      # subscribers/***
      r.on Integer do |phone_number|
        @sub = opts[:subs].sub_by_phone_number(phone_number)
        p phone_number if @sub.nil?
        next if @sub.nil?

        r.is do
          @in_sub = @sub
          view('sub')
        end

        # subscribers/***/delete
        r.on 'delete' do
          r.get do
            @parameters = {}
            view('delete_sub')
          end

          r.post do
            @parameters = DryResultFormeWrapper.new(SubDeleteSchema.call(r.params))
            if @parameters.success?
              opts[:subs].delete_sub(@sub)
              r.redirect('/subscribers')
            else
              view('delete_sub')
            end
          end
        end
      end

      r.on 'new' do
        r.get do
          next if @no_adding # if all numbers are gotten

          @parameters = {}
          @all_plans = opts[:plans].all_plans_names
          view('new_sub')
        end

        r.post do
          @parameters = DryResultFormeWrapper.new(SubAddSchema.call(r.params))
          if @parameters.success?
            phone_number = opts[:subs].new_phone_number
            @no_adding = true if phone_number.nil? # all numbers are gotten

            @in_sub = Sub.new(@parameters[:first_name],
                              @parameters[:last_name],
                              opts[:subs].new_phone_number,
                              opts[:plans].plan_by_name(@parameters[:calling_plan]),
                              0)
            opts[:subs].add_sub(@in_sub)
            view('sub')
          else
            @all_plans = opts[:plans].all_plans_names
            view('new_sub')
          end
        end
      end
    end
  end
end
