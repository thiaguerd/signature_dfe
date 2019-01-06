require "signature_dfe/version"
require "openssl"

module SignatureDfe
	class Error < StandardError; end

	module AbstractClass
		def initialize
			raise "this is a abstract class"
		end
	end

	def self.canonize xml, canonize_method=Nokogiri::XML::XML_C14N_1_1
		Nokogiri::XML(xml.gsub(/>\s+</,"><")).canonicalize(canonize_method)
	end
end

require "signature_dfe/ssl"
require "signature_dfe/nfe"