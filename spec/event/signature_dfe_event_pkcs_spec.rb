RSpec.describe 'SignatureDfe Evento NF-e with pkcs12' do
  before(:all) do
    @pass = rand(36**40).to_s(36)
    @p12_path = "#{GEM_ROOT}/spec/test_files/certs/certificate.p12"
    @key_path = "#{GEM_ROOT}/spec/test_files/certs/key.pem"
    @cert_path = "#{GEM_ROOT}/spec/test_files/certs/certificate.pem"
    BuildCerts.build(
      pass: @pass,
      key_path: @key_path,
      cert_path: @cert_path,
      p12_path: @p12_path
    )
    SignatureDfe::SSL.config.pkcs12 = @p12_path
    SignatureDfe::SSL.config.pkey = nil
    SignatureDfe::SSL.config.password = @pass
    SignatureDfe::SSL.config.cert = nil

    @xml = File.read GEM_ROOT + '/spec/test_files/xml/event/event.xml'

    dh_evento = SignatureDfe::Xml.node_content 'dhEvento', @xml
    @xml.gsub! dh_evento, Time.now.strftime('%Y-%m-%dT%H:%M:%S%:z')

    @sig = SignatureDfe::NFe::Event.sign @xml
    @actual_sig = SignatureDfe::Xml.node_content 'Signature', @xml

    @xml.gsub! @actual_sig, @sig

    @sig2 = SignatureDfe::NFe::Event.sign @xml
  end

  it 'set up ssl' do
    expect(SignatureDfe::SSL.test).to eq(true)
  end

  it 'check digest' do
    expect(SignatureDfe::Check.digest_check(@xml)).to be true
  end

  it 'check sign' do
    expect(SignatureDfe::Check.only_signature_check(@xml)).to be true
  end

  it 'X509Certificate' do
    x509certificate = File.read(@cert_path)
    x509certificate.gsub!(/\-\-\-\-\-[A-Z]+ CERTIFICATE\-\-\-\-\-/, '')
    expect(SignatureDfe::SSL.cert).to eq(x509certificate.strip)
  end
end
