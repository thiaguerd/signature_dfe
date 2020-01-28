module SignatureDfe
  class Xml
    def self.digest_method_algorithm(xml)
      xml.scan(/(\<DigestMethod[\s\S]*?\#)([\s\S]*?)(\"|\')/)[0][1]
    end

    def self.node(name, xml)
      # r = /\<#{Regexp.escape(name)}[\s\S]*?\<\/#{Regexp.escape(name)}\>|(\/\>)/
      r = /\<#{Regexp.escape(name)}[\s\S]*((\/\>)|(#{Regexp.escape(name)}\>))/
      xml.match(r)[0].gsub(/>\s+</, '><')
    end

    def self.node_content(name, xml)
      full_node = xml.scan(%r{\<#{name}.*?\>([\s\S]*?)\</#{name}\>})
      return nil unless full_node[0]

      full_node[0][0]
    end

    def self.node_name(xml)
      xml.scan(/\<[^\/\s\>]*/)[0].gsub('<', '')
    end

    def self.tag(name, xml)
      xml.scan(%r{\<#{name}[\S\s]*?[/\>|\>]})[0]
    end

    def self.namespace_value(namespace, xml)
      matches = xml.match(/#{Regexp.escape(namespace)}\=\"([^"]*)/)
      return nil unless matches

      matches[1]
    end

    def self.get_node_by_namespace_value(value, xml)
      a = xml.match(/\<[^<]*#{Regexp.escape(value)}[^>]*(\>|\/>)/)[0]
      node(node_name(a), xml)
    end

    def self.canonize_inf_nfe(xml)
      tag_inf_nfe = node('infNFe', xml)
      ns = 'xmlns="http://www.portalfiscal.inf.br/nfe"'
      rxg = Regexp.escape(ns)
      canonize(
        if tag_inf_nfe.include?(rxg.to_s)
          tag_inf_nfe
        else
          tag_inf_nfe.gsub(%(<infNFe), %(<infNFe #{ns}))
        end
      )
    end

    def self.signed_info_canonized xml
      canonize(signed_info_with_ns(xml))
    end

    def self.canonize(xml, canonize_method = Nokogiri::XML::XML_C14N_1_1)
      Nokogiri::XML(xml.gsub(/>\s+</, '><')).canonicalize(canonize_method)
    end

    def self.public_cert xml
      x509_certificate = Xml.node_content('X509Certificate', xml)
      x509_certificate = [
        '-----BEGIN CERTIFICATE-----',
        x509_certificate,
        '-----END CERTIFICATE-----'
      ].join("\n")
      OpenSSL::X509::Certificate.new x509_certificate
    end

    def self.signed_info_with_ns xml
      content = Xml.node 'SignedInfo', xml
      canonize content.gsub(
        '<SignedInfo>',
        %(<SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#">)
      )
    end

    def self.canonize_inf_event xml
      inf_evt = node 'infEvento', xml
      canonize(
        if inf_evt.include?(%{xmlns="http://www.portalfiscal.inf.br/nfe"})
          inf_evt
        else
          inf_evt.gsub(%{<infEvento},%{<infEvento xmlns="http://www.portalfiscal.inf.br/nfe"})
        end
      )
    end
  end
end