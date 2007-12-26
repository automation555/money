class AllowanceController < ApplicationController

  def created
    title "Allowance Tasks You've Created"
    @tasks=AllowanceTask.find_all_by_creator_id current_user.id, :order => 'name'
  end

  def new
    title "Create an allowance task"
    if request.post?
      @task=AllowanceTask.new params[:allowance_task]
      @task.creator = current_user
      @task.save!
      flash[:info] = "Created new task:  #{@task.name}"
      redirect_to :action => :created
    else
      @users=User.find :all, :conditions => ["id != ?", current_user.id], :order => 'name'
      @accounts = Hash.new {|h,k| h[k] = []}
      MoneyAccount.find(:all, :conditions => ["active = ?", true], :order => 'name').each do |a|
        if current_user.groups.include? a.group
          @accounts[a.group_id] << a
        end
      end
      @categories = Hash.new {|h,k| h[k] = []}
      Category.find(:all, :order => 'name').each do |c|
        if current_user.groups.include? c.group
          @categories[c.group_id] << c
        end
      end
    end
  end

  def complete
    tids = params['task'].keys.map(&:to_i)
    # To prevent fraud, only include task IDs from those available.
    available = AllowanceTask.find_available(current_user)
    tasks = available.find_all {|n| tids.include? n.id}
    AllowanceTask.transaction do
      tasks.each {|t| t.perform!}
    end
    redirect_to :controller => 'acct', :action => 'index'
  end

end
