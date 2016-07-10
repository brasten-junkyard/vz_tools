 
require 'spec/spec_helper'
require 'vz/container'

include Vz

describe Container, " initialized with veid of 410 and a Node" do
  before do
    SpecHelper.stub_node_for_tests!

    @ve = Container.new( :node => Node.new, :veid => 410)
  end

  it "should return true for #exists?" do
    @ve.should_receive(:vzlist!).and_return(true)
    @ve.exists?.should be_true
  end
end

describe Container, "with valid VEID" do
  before do
    SpecHelper.stub_node_for_tests!

    @ve = Container.new( :node => Node.new, :veid => 410 )
  end

end
