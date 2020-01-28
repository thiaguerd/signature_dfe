RSpec.describe SignatureDfe do
  it 'config is clean' do
    SignatureDfe::SSL.config.clear
    expect(SignatureDfe::SSL.config.pkcs12).to eq(nil)
    expect(SignatureDfe::SSL.config.pkey).to eq(nil)
    expect(SignatureDfe::SSL.config.cert).to eq(nil)
  end

  it 'has a version number' do
    expect(SignatureDfe::VERSION).not_to be nil
  end

  it 'password is not accessible' do
    expect { SignatureDfe::SSL.config.password }.to raise_error(NoMethodError)
  end

  it 'error on test clean setup' do
    expect { SignatureDfe::SSL.test }.to raise_error(SignatureDfe::Error)
  end

  it 'pkey and pkcs12 is empty' do
    SignatureDfe::SSL.config.pkcs12 = nil
    SignatureDfe::SSL.config.pkey = nil
    expect do
      SignatureDfe::SSL.test
    end.to raise_error(SignatureDfe::Error, 'You must be set up pkcs12 or pkey')
  end

  it 'pkcs12 wrong pass' do
    SignatureDfe::SSL.config.pkcs12 = './certs/certificate.p12'
    SignatureDfe::SSL.config.password = 'mybestpasssss'
    msg = "Wrong password for './certs/certificate.p12'"
    expect do
      SignatureDfe::SSL.test
    end.to raise_error(SignatureDfe::Error, msg)
  end

  it 'pkcs12 is right' do
    SignatureDfe::SSL.config.pkcs12 = './certs/certificate.p12'
    SignatureDfe::SSL.config.password = 'mybestpass'
    expect(SignatureDfe::SSL.test).to eq(true)
  end


  context 'SignatureDfe with pkcs12' do
    it 'wrong path pkcs12' do
      path = 'wrong_path'
      SignatureDfe::SSL.config.pkcs12 = path
      msg = "Your pkcs12 '#{path}' is not a valid file"
      expect do
        SignatureDfe::SSL.test
      end.to raise_error(SignatureDfe::Error, msg)
    end

    it 'wrong pass pkcs12' do
      path = './certs/certificate.p12'
      SignatureDfe::SSL.config.pkcs12 = path
      SignatureDfe::SSL.config.password = 'mybestpasssss'
      msg = "Wrong password for '#{path}'"
      expect do
        SignatureDfe::SSL.test
      end.to raise_error(SignatureDfe::Error)
    end

    it 'right on set up wrong pkcs12' do
      path = './certs/certificate.p12'
      SignatureDfe::SSL.config.pkcs12 = path
      SignatureDfe::SSL.config.password = 'mybestpass'
      expect(SignatureDfe::SSL.test).to eq(true)
    end
  end

  context 'SignatureDfe with pkey' do
    it 'wrong path pkey' do
      path = 'wrong_path'
      SignatureDfe::SSL.config.pkcs12 = nil
      SignatureDfe::SSL.config.pkey = path
      msg = "Your pkey '#{path}' is not a valid file"
      expect do
        SignatureDfe::SSL.test
      end.to raise_error(SignatureDfe::Error)
    end

    it 'wrong pass pkey' do
      path = './certs/key.pem'
      SignatureDfe::SSL.config.pkey = path
      SignatureDfe::SSL.config.password = 'mybestpasssss'
      msg = "Wrong password for '#{path}'"
      expect do
        SignatureDfe::SSL.test
      end.to raise_error(SignatureDfe::Error)
    end

    it 'must be set certificate if you using pkey' do
      path = './certs/key.pem'
      SignatureDfe::SSL.config.pkey = path
      SignatureDfe::SSL.config.password = 'mybestpass'
      msg = 'You must be set up the cert if you chose use pkey'
      expect do
        SignatureDfe::SSL.test
      end.to raise_error(SignatureDfe::Error)
    end
    it 'wrong cert' do
      path = './certs/key.pem'
      cert_path = './certs/certificateee.pem'
      SignatureDfe::SSL.config.pkey = path
      SignatureDfe::SSL.config.password = 'mybestpass'
      SignatureDfe::SSL.config.cert = cert_path

      msg = "Your cert '#{cert_path}' is not a valid file"
      expect do
        SignatureDfe::SSL.test
      end.to raise_error(SignatureDfe::Error)
    end
    it 'right on set up with pkey and cert' do
      path = './certs/key.pem'
      cert_path = './certs/certificate.pem'
      SignatureDfe::SSL.config.pkey = path
      SignatureDfe::SSL.config.password = 'mybestpass'
      SignatureDfe::SSL.config.cert = cert_path
      expect(SignatureDfe::SSL.test).to eq(true)
    end
  end

  context 'SignatureDfe NF-e' do
    before(:all) do
      @xml = File.read GEM_ROOT + '/spec/test_files/xml/nfe/valid_nfe.xml'
      @inf_nfe = SignatureDfe::Xml.node 'infNFe', @xml

      signature_value = ''
      x509certificate = ''
      @digest_value = SignatureDfe::Xml.node_content 'DigestValue', @xml
      @signature_value = SignatureDfe::Xml.node_content 'SignatureValue', @xml
      @ch_nfe = '12181004034484000140558900000060011166401389'
      @full_signature = SignatureDfe::Xml.node 'Signature', @xml


    end

    it 'calc digest' do
      expect(SignatureDfe::NFe.digest_value(@xml)).to eq(@digest_value)
    end

    # it 'gen signature_value' do
    #   signature_value = SignatureDfe::NFe.signature_value @ch_nfe, @digest_value
    #   expect(signature_value).to eq(@signature_value)
    # end

    # it 'X509Certificate' do
    #   x509certificate = File.read('./certs/certificate.pem').gsub(/\-\-\-\-\-[A-Z]+ CERTIFICATE\-\-\-\-\-/, '').strip
    #   expect(SignatureDfe::SSL.cert).to eq(x509certificate)
    # end

    # it 'full signature' do
    #   expect(SignatureDfe::NFe.sign(@inf_nfe)).to eq(@full_signature)
    # end
  end
end