class ReportController < ApplicationController

  def index
    title 'Reports'
  end

  def balances
    title 'Reports - Balances'
  end

  def month_flow
    title "Reports - Flow for #{current_user}"
    @flow=[]
    current_user.groups.sort.each do |g|
      gflow=[]
      ActiveRecord::Base.connection.execute(month_flow_query, [g.id]) do |r|
        gflow << r
      end
      @flow << [g, gflow]
    end
    render :action => :flow
  end

  protected

  def month_flow_query(gid)
    query=<<ENDSQL
    select
        date(date_trunc('month', ds)) as theDate,
        sum(amount) as flow
    from
        money_transactions
    where
        deleted_at is null
        and acct_id in
            (select acct_id from money_accounts where group_id = #{gid})
    group by
        theDate
    order by
        theDate desc
ENDSQL
    query
  end

  def authorized?
    current_user.admin?
  end

  def access_denied
    render :action => :access_denied
  end
end
