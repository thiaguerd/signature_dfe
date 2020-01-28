require 'base64'
require 'nokogiri'
module SignatureDfe
	class NFe
		def self.sign something
			if something.is_a? String
				digest_value_ = digest_value something
				
				ch_nfe = something.scan(/\<infnfe[\s\S]*?\>/i)[0].scan(/\d{44}/)[0]

				signature_value_ = signature_value ch_nfe, digest_value_

				%{<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">
					<SignedInfo>
						<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
						<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>
						<Reference URI="#NFe#{ch_nfe}">
							<Transforms>
								<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
								<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
							</Transforms>
							<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>
							<DigestValue>#{digest_value_}</DigestValue>
						</Reference>
					</SignedInfo>
					<SignatureValue>#{signature_value_}</SignatureValue>
					<KeyInfo>
						<X509Data>
							<X509Certificate>#{SignatureDfe::SSL.cert.to_s.gsub(/\-\-\-\-\-[A-Z]+ CERTIFICATE\-\-\-\-\-/, "").strip}</X509Certificate>
						</X509Data>
					</KeyInfo>
				</Signature>}.gsub(/\>\s{1,}\</,"><").strip
			end
		end

		def self.canonize_inf_nfe inf_nfe
			tag_inf_nfe = inf_nfe.scan(/\<infnfe[\s\S]*?\>/i)[0]
			SignatureDfe::Xml.canonize(tag_inf_nfe.include?(%{xmlns="http://www.portalfiscal.inf.br/nfe"}) ? tag_inf_nfe : inf_nfe.gsub(%{<infNFe},%{<infNFe xmlns="http://www.portalfiscal.inf.br/nfe"}))
		end

		def self.signature_value ch_nfe, digest_value
			signed_info = %{
				<SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
					<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
					<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>
					<Reference URI="#NFe#{ch_nfe}">
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

		def self.digest_value something
			inf_nfe = something.scan(/\<infnfe[\s\S]*?\<\/infnfe\>/i)[0].gsub(/>\s+</,"><")
			inf_nfe_canonized = canonize_inf_nfe inf_nfe
			Base64.encode64(OpenSSL::Digest::SHA1.digest(inf_nfe_canonized)).strip
		end
		private_class_method :canonize_inf_nfe
	end
end