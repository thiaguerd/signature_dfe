require 'base64'
require 'nokogiri'
module SignatureDfe
  class NFe
    def self.digest_value(xml)
      SignatureDfe::Xml.calc_digest_value('infNFe', xml)
    end

    def self.sign(xml)
      digest_value_ = digest_value xml
      ch_nfe = SignatureDfe::Xml.namespace_value('Id', xml).scan(/\d{44}/)[0]
      options = {
        id: "NFe#{ch_nfe}",
        digest_value: digest_value_,
        signature_value: signature_value(ch_nfe, digest_value_)
      }
      SignatureDfe::Xml.build_signature(options)
    end

    def self.signature_value(ch_nfe, digest_value)
      SignatureDfe::Xml.build_signed_info("NFe#{ch_nfe}", digest_value)
    end
  end
end
