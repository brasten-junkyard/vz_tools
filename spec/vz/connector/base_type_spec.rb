require 'spec/spec_helper'
require 'vz/connector/base_type'

include Vz::Support
include Vz::Connector

class SimpleBaseType < Vz::Connector::BaseType
  attr_mapping :name
  attr_mapping :realm
end

class ComplexSubType < SimpleBaseType
  attr_mapping :password
end

class MessageType < Vz::Connector::BaseType
  attr_mapping :simple, :type => SimpleBaseType do
    attr_mapping :secret
  end
end

describe BaseType, "#local_name" do
  before do
    @base     = BaseType.new
    @simple   = SimpleBaseType.new
    @message  = MessageType.new
  end
  
  it "should return 'base_type' for BaseType instance" do
    @base.local_name.should == 'base_type'
  end
  
  it "should return 'simple_base_type' for SimpleBaseType instance" do
    @simple.local_name.should == 'simple_base_type'
  end
  
  it "should return 'message_type' for MessageType instance" do
    @message.local_name.should == 'message_type'
  end
end

describe SimpleBaseType do  
  before do
    @schema = SimpleBaseType.schema
  end
  
  it "should include attribute mappings for :name and :realm" do
    @schema.attributes.should include(:name)
    @schema.attributes.should include(:realm)
  end
  
  it "should NOT include attribute mappings for :password" do
    @schema.attributes.should_not include(:password)
  end
end

describe SimpleBaseType, "after MessageType instantiation" do
  before do
    @schema         = MessageType.schema
    @simple_schema  = SimpleBaseType.schema
  end

  it "should not have schema attribute for :secret" do
    @simple_schema.attributes.should_not include(:secret)    
  end
end

describe MessageType do  
  before do
    @simple_schema        = SimpleBaseType.schema
    @schema               = MessageType.schema
    @simple_from_message  = @schema.attributes[:simple].schema
  end
  
  it "should include attribute mappings for :simple" do
    @schema.attributes.should include(:simple)
  end
  
  it "should add the :secret attribute to the SimpleBaseType schema for :simple" do
    @simple_from_message.attributes.should include(:secret)
    @simple_from_message.attributes.should include(:name)
    @simple_from_message.attributes.should include(:realm)
  end
  
  it "should not have directly affected SimpleBaseType's schema" do
    @simple_schema.should_not be_nil
    @simple_schema.attributes.should include(:name)
    @simple_schema.attributes.should include(:realm)
    @simple_schema.attributes.should_not include(:secret)
  end
end

describe ComplexSubType do  
  before do
    @object = ComplexSubType.new
    @schema = ComplexSubType.schema
  end
  
  it "should have accessors for :name, :realm and :password" do
    @object.should respond_to(:name)
    @object.should respond_to(:realm)
    @object.should respond_to(:password)
  end
  
  it "should include attribute mappings for :password" do
    @schema.attributes.should include(:password)
  end
  
  it "should also include super's mappings for :name and :realm" do
    @schema.attributes.should include(:name)
    @schema.attributes.should include(:realm)
  end
end
