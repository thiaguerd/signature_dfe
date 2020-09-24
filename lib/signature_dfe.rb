require 'signature_dfe/version'
require 'signature_dfe_xml'
require 'signature_dfe_check'
require 'openssl'

GEM_ROOT = File.expand_path('..', __dir__)

module SignatureDfe
  class Error < StandardError; end

  def initialize
    raise 'this is a abstract class'
  end

  module AbstractClass
    def initialize
      raise 'this is a abstract class'
    end
  end
end

require 'signature_dfe/config'
require 'signature_dfe/ssl'
require 'signature_dfe/nfe'
require 'signature_dfe/evento_nfe'
require 'signature_dfe/disabling'
