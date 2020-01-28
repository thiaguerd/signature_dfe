module SignatureDfe
  class Config
    include AbstractClass

    attr_accessor :pkcs12, :pkey, :cert

    attr_writer :password

    def initialize
      @pkcs12 = nil
      @pkey = nil
      @cert = nil
      @password = nil
    end

    def inspect
      super.gsub(/\, \@pass[\s\S]*?\>/, '>')
    end

    def instance_variables
      super - [:@password]
    end
  end

  class SSL
    include AbstractClass

    @@config = Config.new

    def self.config
      @@config
    end

    def self.sign(content, sign_method = OpenSSL::Digest::SHA1.new)
      self.test unless defined?(@@pk)
      @@pk.sign sign_method, content
    end

    def self.cert
      self.test unless defined?(@@pk)
      @@cert.to_s.gsub(/\-\-\-\-\-[A-Z]+ CERTIFICATE\-\-\-\-\-/, '').strip
    end

    def self.test
      if (config.pkcs12.nil? || config.pkcs12.empty?) && (config.pkey.nil? || config.pkey.empty?)
        raise SignatureDfe::Error, 'You must be set up pkcs12 or pkey'
       end

      if config.pkcs12
        if File.exist? config.pkcs12
          begin
            aux = OpenSSL::PKCS12.new(File.read(config.pkcs12), config.instance_variable_get(:@password))
            @@pk = aux.key
            @@cert = aux.certificate
          rescue OpenSSL::PKCS12::PKCS12Error => e
            raise SignatureDfe::Error, "Wrong password for '#{config.pkcs12}'"
          end
        else
          raise SignatureDfe::Error, "Your pkcs12 '#{config.pkcs12}' is not a valid file"
        end
      elsif config.pkey
        if File.exist? config.pkey
          begin
            @@pk = OpenSSL::PKey::RSA.new File.read(config.pkey), config.instance_variable_get(:@password)
            begin
              if config.cert.nil? || config.cert.empty?
                raise SignatureDfe::Error, 'You must be set up the cert if you chose use pkey'
      end
              unless File.exist? config.cert
                raise SignatureDfe::Error, "Your cert '#{config.cert}' is not a valid file"
      end

              @@cert = OpenSSL::X509::Certificate.new(File.read(config.cert))
            rescue OpenSSL::X509::CertificateError => e
              raise SignatureDfe::Error, "Your cert '#{config.cert}' is not a valid file"
            end
          rescue OpenSSL::PKey::RSAError => e
            raise SignatureDfe::Error, "Wrong password for '#{config.pkey}'"
          end
        else
          raise SignatureDfe::Error, "Your pkey '#{config.pkey}' is not a valid file"
        end
      end
      true
    end
  end
end
