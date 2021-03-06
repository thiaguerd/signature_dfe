module SignatureDfe
  class SSL
    include AbstractClass

    @config = Config.new

    class << self
      attr_reader :config
    end

    def self.sign(content, sign_method = OpenSSL::Digest.new('SHA1'))
      self.test unless defined?(@pk)
      @pk.sign sign_method, content
    end

    def self.cert
      self.test unless defined?(@pk)
      @cert.to_s.gsub(/-----[A-Z]+ CERTIFICATE-----/, '').strip
    end

    class << self
      def test
        set_up
        test_pkc12 if config.pkcs12
        test_pem if config.pkey && !config.pkcs12
        true
      rescue OpenSSL::PKey::RSAError
        error "Wrong password for '#{config.pkey}'"
      end

      private

      def error(msg)
        raise SignatureDfe::Error, msg
      end

      def check_pkcs12
        (config.pkcs12.nil? || config.pkcs12.empty?)
      end

      def check_pem
        (config.pkey.nil? || config.pkey.empty?)
      end

      def set_up
        error 'You must be set up pkcs12 or pkey' if check_pkcs12 && check_pem
      end

      def load_pkcs12
        pass = config.instance_variable_get(:@password)
        aux = OpenSSL::PKCS12.new(File.read(config.pkcs12), pass)
        @pk = aux.key
        @cert = aux.certificate
      rescue OpenSSL::PKCS12::PKCS12Error
        error "Wrong password for '#{config.pkcs12}'"
      end

      def test_pkc12
        if File.exist? config.pkcs12
          load_pkcs12
        else
          error "Your pkcs12 '#{config.pkcs12}' is not a valid file"
        end
      end

      def check_cert
        error 'You must be set up the cert if you chose use pkey' unless config.cert?
        if File.exist? config.cert
          @cert = OpenSSL::X509::Certificate.new(File.read(config.cert))
        else
          error "Your cert '#{config.cert}' is not a valid file"
        end
      end

      def test_pem
        if File.exist? config.pkey
          pass = config.instance_variable_get(:@password)
          @pk = OpenSSL::PKey::RSA.new File.read(config.pkey), pass
          check_cert
        else
          error "Your pkey '#{config.pkey}' is not a valid file"
        end
      rescue OpenSSL::X509::CertificateError
        error "Your cert '#{config.cert}' is not a valid file"
      end
    end
  end
end
