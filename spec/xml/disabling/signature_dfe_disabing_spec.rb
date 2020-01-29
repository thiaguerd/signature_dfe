require 'build_certs'

RSpec.describe SignatureDfe::Inutilizacao do
  context 'valid event' do
    it 'digest_check true' do
      xml = File.read GEM_ROOT + '/spec/test_files/xml/disabling/valid.xml'
      expect(SignatureDfe::Check.digest_check(xml)).to be true
    end

    it 'signature_check true' do
      xml = File.read GEM_ROOT + '/spec/test_files/xml/disabling/valid.xml'
      expect(SignatureDfe::Check.signature_check(xml)).to be true
    end
  end

  context 'build a xml' do
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
    end
    it 'rewrite signature' do
      SignatureDfe::SSL.config.pkcs12 = @p12_path
      SignatureDfe::SSL.config.password = @pass
      expect(SignatureDfe::SSL.test).to eq(true)
      xml = File.read GEM_ROOT + '/spec/test_files/xml/disabling/valid.xml'
      inf_evento = SignatureDfe::Xml.node 'infInut', xml
      new_signature = SignatureDfe::Inutilizacao.sign inf_evento
      original_signature = SignatureDfe::Xml.node 'Signature', xml
      expect(original_signature).to_not eq new_signature
      new_xml = xml.gsub(original_signature, new_signature)
      expect(SignatureDfe::Check.digest_check(new_xml)).to be true
      expect(SignatureDfe::Check.signature_check(new_xml)).to be true
    end
    after(:all) do
      File.delete "#{GEM_ROOT}/spec/test_files/certs/certificate.p12"
      File.delete "#{GEM_ROOT}/spec/test_files/certs/key.pem"
      File.delete "#{GEM_ROOT}/spec/test_files/certs/certificate.pem"
    end
  end
end
