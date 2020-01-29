module SignatureDfe
  class Check
    def self.only_signature_check(xml)
      signed_info_canonized = Xml.signed_info_canonized xml
      certificate = Xml.public_cert xml
      certificate.public_key.verify(
        OpenSSL::Digest.new(Xml.digest_method_algorithm(signed_info_canonized)),
        Base64.decode64(Xml.node_content('SignatureValue', xml)),
        signed_info_canonized
      )
    end

    def self.signature_check(xml)
      return false unless digest_check(xml)

      only_signature_check(xml)
    end

    def self.digest_check(xml)
      uri = Xml.namespace_value('URI', Xml.tag('Reference', xml)).gsub('#', '')
      xmlns = Xml.namespace_value('xmlns', xml)
      node_assigned = Xml.get_node_by_namespace_value(uri, xml)
      node_assigned.gsub!(/>\s+\</, '><')
      node_name = Xml.node_name(node_assigned)
      unless Xml.tag(node_name, xml).include?(xmlns)
        node_assigned.gsub!(node_name, %(#{node_name} xmlns="#{xmlns}"))
      end
      dv = OpenSSL::Digest::SHA1.digest(Xml.canonize(node_assigned))
      Base64.encode64(dv).strip == Xml.node_content('DigestValue', xml)
    end
  end
end
