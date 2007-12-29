require File.dirname(__FILE__) + '/../test_helper'
require 'allowance_controller'
require 'allowance_task'

# Re-raise errors caught by the controller.
class AllowanceController; def rescue_action(e) raise e end; end

class AllowanceTask
  def AllowanceTask.count_active
    count :conditions => ['deleted = ?', false]
  end
end

class AllowanceControllerTest < Test::Unit::TestCase

  include AuthenticatedTestHelper

  fixtures :users, :allowance_tasks, :allowance_logs, :groups, :categories
  fixtures :money_transactions

  def setup
    @controller = AllowanceController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_complete
    login_as :aaron
    assert_difference MoneyTransaction, :count, 4 do
      post :complete, :task => {"1" => "on", "3" => "on"}
    end
  end

  def test_redoing_unavailable
    login_as :aaron
    assert_difference MoneyTransaction, :count, 0 do
      post :complete, :task => {"2" => "on"}
    end
  end

  def test_created
    login_as :dustin
    get :created
    assert_response :success
    assert_equal [2, 1, 4, 3], assigns['tasks'].map(&:id)
    assert_equal 8.35, assigns['weekly_sum']
  end

  def test_new_form
    login_as :dustin
    get :new
    assert_response :success
    assert !assigns['users'].map(&:id).include?(users(:dustin).id)

    assert_equal [1,2], assigns['categories'].keys
    assert_equal [1,2], assigns['accounts'].keys

    assert_equal [1,2], assigns['accounts'][1].map(&:id)
    assert_equal [3], assigns['accounts'][2].map(&:id)

    assert_equal [1,2], assigns['categories'][1].map(&:id)
    assert_equal [3], assigns['categories'][2].map(&:id)
  end

  def test_new_form_aaron
    login_as :aaron
    get :new
    assert_response :success
    assert !assigns['users'].map(&:id).include?(users(:aaron).id)
    assert_equal [1], assigns['categories'].keys
    assert_equal [1], assigns['accounts'].keys
  end

  def test_new
    login_as :dustin
    assert_difference AllowanceTask, :count do
      post :new, :allowance_task => {
        :name => 'Test Task', :description => 'A test task.', :owner_id => 2,
        :frequency => 2, :value => 1.29,
        :from_money_account_id => 3, :from_category_id => 3,
        :to_money_account_id => 1, :to_category_id => 1
        }
      assert_response :redirect
    end
  end

  def test_deactivation
    login_as :dustin
    assert_difference AllowanceTask, :count_active, -1 do
      xhr :post, :task_toggle, :id => 1, :active => 'false'
      assert_response :success
      assert_template 'allowance/deactivate'
    end
  end

  def test_activation
    login_as :dustin
    assert_difference AllowanceTask, :count_active do
      xhr :post, :task_toggle, :id => 4, :active => 'true'
      assert_response :success
      assert_template 'allowance/activate'
    end
  end

end
