require 'base64'
require 'nokogiri'

module SignatureDfe
  class NFe
    class Event
      def self.digest_value(xml)
        SignatureDfe::Xml.calc_digest_value(xml, 'infEvento')
      end

      def self.signature_value(event_id, digest_value)
        SignatureDfe::Xml.build_signed_info(event_id, digest_value)
      end

      def self.sign(xml)
        digest_value_ = digest_value xml
        event_id = SignatureDfe::Xml.namespace_value('Id', xml)
        options = {
          id: event_id,
          digest_value: digest_value_,
          signature_value: signature_value(event_id, digest_value_)
        }
        SignatureDfe::Xml.build_signature(options)
      end
    end
  end
end
