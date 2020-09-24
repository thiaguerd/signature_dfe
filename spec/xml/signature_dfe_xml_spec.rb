require 'build_certs'

RSpec.describe SignatureDfe::Xml do
  it 'test canonize' do
    xml = '<a/>'
    xml_canonized = SignatureDfe::Xml.canonize xml
    expect(xml_canonized).to eq '<a></a>'
  end

  it 'test canonize' do
    xml = '<a b="b" a="a"/>'
    xml_canonized = SignatureDfe::Xml.canonize xml
    expect(xml_canonized).to eq '<a a="a" b="b"></a>'
  end

  it 'test canonize' do
    xml = '<a b="b" a="a" > <b/> </ a >'
    xml_canonized = SignatureDfe::Xml.canonize xml
    expect(xml_canonized).to eq '<a a="a" b="b"><b></b></a>'
  end

  %w[det cUF].each do |tag_name|
    it "test node #{tag_name}" do
      xml = File.read path('spec/test_files/xml/nfe/valid_nfe.xml')
      node = SignatureDfe::Xml.node tag_name, xml
      match_start = "<#{tag_name}"
      math_end = "</#{tag_name}>"
      index_match_start = xml.index(match_start)
      index_math_end = xml.index(math_end) + math_end.size - 1
      node_from_xml = xml[index_match_start..index_math_end]
      expect(node_from_xml).to eq node
    end
  end

  it 'test node empty' do
    xml = '<a><b><c ns="something"/></b></a>'
    node = SignatureDfe::Xml.node 'c', xml
    expect(node).to eq('<c ns="something"/>')
  end

  it 'test node empty' do
    xml = '<aa><bb><cc ns="something"/></bb></aa>'
    node = SignatureDfe::Xml.node 'cc', xml
    expect(node).to eq('<cc ns="something"/>')
  end

  it 'test node' do
    xml = '<aa><bb><cc>node_content</cc></bb></aa>'
    node = SignatureDfe::Xml.node 'cc', xml
    expect(node).to eq('<cc>node_content</cc>')
  end

  it 'test node_content' do
    xml = '<a><b><c>123</c></b></a>'
    node_content = SignatureDfe::Xml.node_content 'c', xml
    expect(node_content).to eq '123'
  end

  it 'test node SignedInfo' do
    xml = '<a><SignedInfo><b/></SignedInfo></a>'
    expect_xml = '<SignedInfo><b/></SignedInfo>'
    expect(SignatureDfe::Xml.node('SignedInfo', xml)).to eq expect_xml
  end

  it 'test empty node_content' do
    xml = '<a><b><c/></b></a>'
    node_content = SignatureDfe::Xml.node_content 'c', xml
    expect(node_content).to eq nil
  end

  it 'test blank node_content' do
    xml = '<a><b><c></c></b></a>'
    node_content = SignatureDfe::Xml.node_content 'c', xml
    expect(node_content).to eq ''
  end

  it 'test node_name' do
    xml = '<a><b><c></c></b></a>'
    node_content = SignatureDfe::Xml.node_name xml
    expect(node_content).to eq 'a'
  end

  it 'test node_name empty' do
    xml = '<a/>'
    node_content = SignatureDfe::Xml.node_name xml
    expect(node_content).to eq 'a'
  end

  it 'test node_name empty with namespace' do
    xml = '<aBc ns="something"/>'
    node_content = SignatureDfe::Xml.node_name xml
    expect(node_content).to eq 'aBc'
  end

  it 'test tag' do
    xml = '<a><b><c></c></b></a>'
    node_content = SignatureDfe::Xml.tag 'a', xml
    expect(node_content).to eq '<a>'
  end

  it 'test tag with namespace' do
    xml = '<a x="something"><b><c></c></b></a>'
    node_content = SignatureDfe::Xml.tag 'a', xml
    expect(node_content).to eq '<a x="something">'
  end

  it 'test namespace_value' do
    xml = '<a x="something"><b><c></c></b></a>'
    node_content = SignatureDfe::Xml.namespace_value 'x', xml
    expect(node_content).to eq 'something'
  end

  it 'test namespace_value with other namespaces' do
    xml = '<a x="something"><b y="other_thing"><c></c></b></a>'
    node_content = SignatureDfe::Xml.namespace_value 'x', xml
    expect(node_content).to eq 'something'
  end

  it 'test get_node_by_namespace_value' do
    xml = '<a><b><c x="ns_val">321</c></b></a>'
    node_content = SignatureDfe::Xml.get_node_by_namespace_value 'ns_val', xml
    expect(node_content).to eq '<c x="ns_val">321</c>'
  end

  it 'test get_node_by_namespace_value emtpy node' do
    xml = '<a><b><c x="ns_val"/></b></a>'
    node_content = SignatureDfe::Xml.get_node_by_namespace_value 'ns_val', xml
    expect(node_content).to eq '<c x="ns_val"/>'
  end

  it 'test get_node_by_namespace_value with another namespace' do
    xml = '<a><b><c x="ns_val" y="another_ns" /><e x="ns_val"></b></a>'
    node_content = SignatureDfe::Xml.get_node_by_namespace_value 'ns_val', xml
    expect(node_content).to eq '<c x="ns_val" y="another_ns" />'
  end

  it 'test canonize_inf_nfe' do
    xml = %(
      <infNFe versao="4.00" Id="xyz">
        <d/>
      </infNFe>
    )
    canonized = SignatureDfe::Xml.canonize_inf_nfe xml
    expected = %(
      <infNFe xmlns="http://www.portalfiscal.inf.br/nfe" Id="xyz" versao="4.00">
        <d></d>
      </infNFe>
    ).gsub(/(\s{2,}|\n)/, '')
    expect(canonized).to eq expected
  end

  it 'test signed_info_with_ns' do
    xml = '<a><SignedInfo></SignedInfo></a>'
    expect_xml = %(
      <SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#"></SignedInfo>
    ).strip
    expect(expect_xml).to eq SignatureDfe::Xml.signed_info_with_ns(xml)
  end

  it 'test signed_info_with_ns with content' do
    xml = '<a><SignedInfo><b/></SignedInfo></a>'
    expect_xml = %(
      <SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
        <b></b>
      </SignedInfo>).strip.gsub(/>\s+</, '><')
    expect(SignatureDfe::Xml.signed_info_with_ns(xml)).to eq expect_xml
  end

  it 'test signed_info_canonized' do
    xml = '<a><SignedInfo><b/></SignedInfo></a>'
    expect_xml = %(
      <SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
        <b></b>
      </SignedInfo>
    ).gsub(/(\s{2,}|\n)/, '')
    expect(SignatureDfe::Xml.signed_info_canonized(xml)).to eq expect_xml
  end

  it 'test public_cert' do
    xml = File.read path('spec/test_files/xml/nfe/valid_nfe.xml')
    expect(SignatureDfe::Xml.public_cert(xml).subject).to_not be_nil
  end

  it 'test canonize_inf_event' do
    xml = %(
      <infEvento Id="NFe121">
        <d/>
      </infEvento>
    )
    canonized = SignatureDfe::Xml.canonize_with_ns xml, 'infEvento'
    expected = %(
      <infEvento xmlns="http://www.portalfiscal.inf.br/nfe" Id="NFe121">
        <d></d>
      </infEvento>
    ).gsub(/(\s{2,}|\n)/, '')
    expect(canonized).to eq expected
  end
end
