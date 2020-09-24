require 'build_certs'

RSpec.describe SignatureDfe::NFe::Event do
  context 'valid event' do
    it 'digest_check true' do
      xml = File.read path('spec/test_files/xml/event/event.xml')
      expect(SignatureDfe::Check.digest_check(xml)).to be true
    end

    it 'signature_check true' do
      xml = File.read path('spec/test_files/xml/event/event.xml')
      expect(SignatureDfe::Check.signature_check(xml)).to be true
    end
  end

  context 'build a xml' do
    before(:all) do
      @pass = rand(36**40).to_s(36)
      @p12_path = path('spec/test_files/certs/certificate.p12')
      @key_path = path('spec/test_files/certs/key.pem')
      @cert_path = path('spec/test_files/certs/certificate.pem')
      BuildCerts.build(
        pass: @pass,
        key_path: @key_path,
        cert_path: @cert_path,
        p12_path: @p12_path
      )
    end
    it 'rewrite signature' do
      SignatureDfe::SSL.config.pkcs12 = @p12_path
      SignatureDfe::SSL.config.password = @pass
      expect(SignatureDfe::SSL.test).to eq(true)
      xml = File.read path('spec/test_files/xml/event/event.xml')
      inf_evento = SignatureDfe::Xml.node 'infEvento', xml
      new_signature = SignatureDfe::NFe::Event.sign inf_evento
      original_signature = SignatureDfe::Xml.node 'Signature', xml
      expect(original_signature).to_not eq new_signature
      new_xml = xml.gsub(original_signature, new_signature)
      expect(SignatureDfe::Check.digest_check(new_xml)).to be true
      expect(SignatureDfe::Check.signature_check(new_xml)).to be true
    end
    after(:all) do
      File.delete path('spec/test_files/certs/certificate.p12')
      File.delete path('spec/test_files/certs/key.pem')
      File.delete path('spec/test_files/certs/certificate.pem')
    end
  end

  context 'invalid_digest_nfe' do
    before(:all) do
      @xml = File.read path('spec/test_files/xml/event/event.xml')
      @xml.gsub!('<cOrgao>51</cOrgao>', '<cOrgao>52</cOrgao>')
    end

    it 'digest_check true' do
      expect(SignatureDfe::Check.digest_check(@xml)).to be false
    end

    it 'signature_check still true' do
      expect(SignatureDfe::Check.only_signature_check(@xml)).to be true
    end
  end

  context 'invalid_signature_nfe' do
    before(:all) do
      @xml = File.read path('spec/test_files/xml/event/event.xml')
      x509certificate = SignatureDfe::SSL.cert
      old_cert = SignatureDfe::Xml.node_content 'X509Certificate', @xml
      @new_xml = @xml.gsub(old_cert, x509certificate)
    end

    it 'digest_check true' do
      expect(SignatureDfe::Check.digest_check(@new_xml)).to be true
    end

    it 'signature_check false' do
      expect(SignatureDfe::Check.only_signature_check(@new_xml)).to be false
    end
  end

  context 'invalid_signature_and_digest_value_nfe' do
    before(:all) do
      @xml = File.read path('spec/test_files/xml/event/event.xml')
      @xml.gsub!('<cOrgao>51</cOrgao>', '<cOrgao>52</cOrgao>')
      x509certificate = SignatureDfe::SSL.cert
      old_cert = SignatureDfe::Xml.node_content 'X509Certificate', @xml
      @new_xml = @xml.gsub(old_cert, x509certificate)
    end

    it 'digest_check true' do
      expect(SignatureDfe::Check.digest_check(@new_xml)).to be false
    end

    it 'signature_check false' do
      expect(SignatureDfe::Check.signature_check(@new_xml)).to be false
    end
  end
end
