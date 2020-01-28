require 'base64'
require 'nokogiri'

module SignatureDfe
	class NFe
		class Event

			def self.digest_value xml
				inf_event = SignatureDfe::Xml.node('infEvento', xml)
				inf_event_canonized = SignatureDfe::Xml.canonize_inf_event inf_event
				Base64.encode64(OpenSSL::Digest::SHA1.digest(inf_event_canonized)).strip
			end

			def self.signature_value event_id, digest_value
				signed_info = %{
					<SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
						<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
						<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>
						<Reference URI="##{event_id}">
							<Transforms>
								<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
								<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
							</Transforms>
							<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>
							<DigestValue>#{digest_value}</DigestValue>
						</Reference>
					</SignedInfo>
				}
				signed_info_canonized = SignatureDfe::Xml.canonize signed_info
				Base64.encode64(SignatureDfe::SSL.sign signed_info_canonized).strip
			end

			def self.sign xml
				digest_value_ = digest_value xml

				event_id = SignatureDfe::Xml.namespace_value('Id', xml).scan(/\d/).join("")
				event_id = SignatureDfe::Xml.namespace_value('Id', xml)
								
				signature_value_ = signature_value event_id, digest_value_
				path = "#{GEM_ROOT}/lib/signature_dfe/templates/signature.xml"
				signature_template = File.read path
				signature_template.gsub!(':id', event_id)
				signature_template.gsub!(':digest_value', digest_value_)
				signature_template.gsub!(':signature_value', signature_value_)
				
				cert = SignatureDfe::SSL.cert.to_s
				cert.to_s.gsub!(/\-\-\-\-\-[A-Z]+ CERTIFICATE\-\-\-\-\-/, "")
				signature_template.gsub!(':x509_certificate', cert.strip).gsub(/\>\s{1,}\</,"><").strip
			end
		end
	end
end
