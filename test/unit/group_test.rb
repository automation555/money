require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < Test::Unit::TestCase
  fixtures :groups, :group_user_map, :users, :money_accounts, :categories

  def test_create
    g=Group.new :name => "Test Group"
    g.save
    assert_equal(g, Group.find(3))
  end

  def test_list_users
    assert_equal([1, 2], Group.find(1).users.map(&:id).sort)
  end

  def test_list_users2
    assert_equal([1], Group.find(2).users.map(&:id).sort)
  end

  def test_list_accounts
    assert_equal([1, 2], Group.find(1).accounts.map(&:id).sort)
  end

  def test_list_accounts2
    assert_equal([3], Group.find(2).accounts.map(&:id))
  end

  def test_balance
    assert_equal(481.68, Group.find(1).balance)
  end

  def test_balance_empty
    assert_equal(0, Group.find(2).balance)
  end
end
