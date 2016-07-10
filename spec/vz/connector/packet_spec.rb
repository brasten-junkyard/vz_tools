require 'spec/spec_helper'
require 'vz/connector/packet'
require 'vz/support/marshaller'

include Vz::Connector

$REALMS_XML =<<-EOV 
<packet xmlns:ns3="http://www.swsoft.com/webservices/vzl/4.0.0/types" 
        xmlns:ns1="http://www.swsoft.com/webservices/vzl/4.0.0/protocol" 
        xmlns:ns2="http://www.swsoft.com/webservices/vzl/4.0.0/dirm" 
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
        id="8c46b82a5at18berf28" priority="0" version="4.0.0"> 
  <origin>system</origin> 
  <target>vzclient4-2cbbe469-8f57-7f46-97fb-fd987231d957</target> 
  <data> 
    <system> 
      <realms> 
        <realm xsi:type="ns2:dir_realmType"> 
          <login> 
            <name>Y249dnphZ2VudCxkYz1WWkw=</name> 
            <realm>3e761571-6607-1344-a064-a42679da8ed9</realm> 
          </login> 
          <builtin/> 
          <name>Virtuozzo Internal</name> 
          <type>1</type> 
          <id>3e761571-6607-1344-a064-a42679da8ed9</id> 
          <address>vzsveaddress</address> 
          <port>389</port> 
          <base_dn>dc=vzl</base_dn> 
          <default_dn>cn=users,dc=vzl</default_dn> 
        </realm> 
        <realm xsi:type="ns3:realmType"> 
          <builtin/> 
          <name>System</name> 
          <type>0</type> 
          <id>00000000-0000-0000-0000-000000000000</id> 
        </realm> 
        <realm xsi:type="ns3:realmType"> 
          <builtin/> 
          <name>Virtuozzo VE</name> 
          <type>1000</type> 
          <id>00000000-0000-0000-0100-000000000000</id> 
        </realm> 
      </realms> 
    </system> 
  </data> 
</packet>
EOV

$TARGET_ONE =<<EOV
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<packet version="4.0.0" id="12345">
  <data>
    <system>
      <test>
        <message>Yo</message>
      </test>
    </system>
  </data>
</packet>
EOV

$TARGET_TWO =<<EOV
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<packet version="4.0.0" id="12345">
  <target>authm</target>
  <data>
    <authm>
      <test>
        <message>Hello</message>
      </test>
      <test>
        <message>There</message>
      </test>
    </authm>
  </data>
</packet>
EOV

class TestType < Vz::Connector::BaseType
  attr_accessor :message
  
  def marshal( options={} )
    xml = options[:builder]
    
    xml.test do
      xml.message( self.message )
    end
  end
end

describe Packet do
  before do
    @packet = Packet.new( :message_id => '12345' )
  end
  
  it "should marshal TestType message for system interface as expected" do
    @packet.interface = :system
    @packet << TestType.new( :message => 'Yo' )
    
    @packet.marshal.should == $TARGET_ONE
  end

  it "should marshal multiple TestType messages for authm interface as expected" do
    @packet.interface = :authm
    @packet << TestType.new( :message => 'Hello' )
    @packet << TestType.new( :message => 'There' )
    
    @packet.marshal.should == $TARGET_TWO
  end  
end

describe Packet, "unmarshalled from Realms XML" do
  
  before do
    @packet = Vz::Support::Marshaller.unmarshal( $REALMS_XML, :class => Packet )
  end
  
  it "should have message_id of '8c46b82a5at18berf28'" do
    @packet.message_id.should == '8c46b82a5at18berf28'
  end  
  
  it "should have interface of 'system'" do
    @packet.interface.should == :system
  end  

  it "should have 1 message" do
    Vz.log( :debug,  @packet.inspect )
    @packet.should have(1).messages
  end  
end
