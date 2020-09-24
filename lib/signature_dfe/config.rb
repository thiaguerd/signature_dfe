module SignatureDfe
  class Config
    include AbstractClass

    attr_accessor :pkcs12, :pkey, :cert

    attr_writer :password

    def initialize
      clear
    end

    def clear
      @pkcs12 = nil
      @pkey = nil
      @cert = nil
      @password = nil
    end

    def inspect
      super.gsub(/, @pass[\s\S]*?>/, '>')
    end

    def cert?
      !(cert.nil? || cert.empty?)
    end

    def instance_variables
      super - [:@password]
    end
  end
end
