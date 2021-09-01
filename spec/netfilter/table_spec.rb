#encoding: utf-8
require 'spec_helper'
describe NetfilterManager::Table do
  describe "Instance Methods" do
    describe "chain" do
      it "should not create a new chain if one with the same name already exists" do
        tool = NetfilterManager::Tool.new
        tool.table("filter").chain("test1")
        tool.table("filter").chain("test2")
        tool.table("filter").chain(:test1)
        tool.table("filter").chains.count.should eq(2)
      end
    end
  end
end
