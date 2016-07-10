
require 'spec/spec_helper'

require 'vz/node'
require 'vz/connector/interface/service_proxy'
require 'vz/support/mapped_struct'

include Vz

describe Node, '#containers' do
  before do
    proxy = mock('Proxy')
    proxy.should_receive(:get_info).once.and_return( build_containers() )
    Vz::Connector::Interface::Proxy.stub!(:new).and_return( proxy )

    @node = Node.new
  end

  it "should return 9 containers" do
    @node.should have(9).containers
  end

  it "should include VE 555555555555555" do
    @node.containers.find { |f| f.eid == '555555555555555' }.should_not be_nil
  end

  def build_container_eids
    (0...9).map { |idx| (idx.to_s * 15) }
  end

  def build_containers
    build_container_eids.map { |eid|
      Vz::Connector::Env.new(
        :eid              => eid,
        :parent_eid       => eid,
        :status           => Vz::Connector::EnvStatus.new( :state => 6, :transition => nil ),
        :virtual_config   => Vz::Support::MappedStruct.new(
          :hostname => 'node1.nagilumve.com',
          :qos      => (0..10).map { Vz::Support::MappedStruct.new( :id => 'test_id', :limit => 100, :barrier => 70 ) } )
      )
    }
  end
end

describe Node, "#find_container_by_eid('410')" do
  before do
    proxy = mock('Proxy')
    proxy.should_receive(:get_info).with(:eid => '410').once.and_return( build_container() )
    Vz::Connector::Interface::Proxy.stub!(:new).and_return( proxy )

    @ve = Node.new().find_container_by_eid('410')
  end

  it "should return a VE" do
    @ve.should be_kind_of(Container)
  end

  it "should return VE with veid of 410" do
    @ve.eid.should == '410'
  end

  it "should return VE with hostname of node1.nagilumve.com" do
    @ve.hostname.should == "node1.nagilumve.com"
  end

  def build_container
    Vz::Connector::Env.new(
      :eid              => '410',
      :parent_eid       => '400',
      :status           => Vz::Connector::EnvStatus.new( :state => 6, :transition => nil ),
      :virtual_config   => OpenStruct.new(
        :hostname => 'node1.nagilumve.com', 
        :qos              => (0..10).map { Vz::Support::MappedStruct.new( :id => 'test_id', :limit => 100, :barrier => 70 ) } )
    )
  end
end
