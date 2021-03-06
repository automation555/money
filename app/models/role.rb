# == Schema Information
# Schema version: 9
#
# Table name: roles
#
#  id   :integer       not null, primary key
#  name :string(16)    not null
#

class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :class_name => "User",
    :join_table => "user_roles_map"

    attr_accessible :name

  def to_s
    name
  end
end
