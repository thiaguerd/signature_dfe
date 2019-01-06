RSpec.describe "SignatureDfe" do
	it "config is clean" do
		expect(SignatureDfe::SSL.config.pkcs12).to eq(nil)
		expect(SignatureDfe::SSL.config.pkey).to eq(nil)
		expect(SignatureDfe::SSL.config.cert).to eq(nil)
	end

	it "has a version number" do
		expect(SignatureDfe::VERSION).not_to be nil
	end

	it "password is not accessible" do
		expect{SignatureDfe::SSL.config.password}.to raise_error(NoMethodError)
	end

	it "error on test clean setup" do
		expect{SignatureDfe::SSL.test}.to raise_error(SignatureDfe::Error)
	end

	it "pkey and pkcs12 is empty" do
		SignatureDfe::SSL.config.pkcs12 = nil
		SignatureDfe::SSL.config.pkey = nil
		expect{SignatureDfe::SSL.test}.to raise_error(SignatureDfe::Error, "You must be set up pkcs12 or pkey")
	end

	it "pkcs12 wrong pass" do
		SignatureDfe::SSL.config.pkcs12 = "./certs/certificate.p12"
		SignatureDfe::SSL.config.password = 'mybestpasssss'
		expect{SignatureDfe::SSL.test}.to raise_error(SignatureDfe::Error, "Wrong password for './certs/certificate.p12'")
	end

	it "pkcs12 is right" do
		SignatureDfe::SSL.config.pkcs12 = "./certs/certificate.p12"
		SignatureDfe::SSL.config.password = 'mybestpass'
		expect(SignatureDfe::SSL.test).to eq(true)
	end
end

RSpec.describe "SignatureDfe with pkcs12" do
	it "wrong path pkcs12" do
		path = "wrong_path"
		SignatureDfe::SSL.config.pkcs12 = path
		expect{SignatureDfe::SSL.test}.to raise_error(SignatureDfe::Error, "Your pkcs12 '#{path}' is not a valid file")
	end

	it "wrong pass pkcs12" do
		path = "./certs/certificate.p12"
		SignatureDfe::SSL.config.pkcs12 = path
		SignatureDfe::SSL.config.password  = 'mybestpasssss'
		expect{SignatureDfe::SSL.test}.to raise_error(SignatureDfe::Error, "Wrong password for '#{path}'")
	end

	it "right on set up wrong pkcs12" do
		path = "./certs/certificate.p12"
		SignatureDfe::SSL.config.pkcs12 = path
		SignatureDfe::SSL.config.password  = 'mybestpass'
		expect(SignatureDfe::SSL.test).to eq(true)
	end

end

RSpec.describe "SignatureDfe with pkey" do
	it "wrong path pkey" do
		path = "wrong_path"
		SignatureDfe::SSL.config.pkcs12 = nil
		SignatureDfe::SSL.config.pkey = path
		expect{SignatureDfe::SSL.test}.to raise_error(SignatureDfe::Error, "Your pkey '#{path}' is not a valid file")
	end

	it "wrong pass pkey" do
		path = "./certs/key.pem"
		SignatureDfe::SSL.config.pkey = path
		SignatureDfe::SSL.config.password  = 'mybestpasssss'
		expect{SignatureDfe::SSL.test}.to raise_error(SignatureDfe::Error, "Wrong password for '#{path}'")
	end

	it "must be set certificate if you using pkey" do
		path = "./certs/key.pem"
		SignatureDfe::SSL.config.pkey = path
		SignatureDfe::SSL.config.password  = 'mybestpass'
		expect{SignatureDfe::SSL.test}.to raise_error(SignatureDfe::Error, "You must be set up the cert if you chose use pkey")

	end
	it "wrong cert" do
		path = "./certs/key.pem"
		cert_path = "./certs/certificateee.pem"
		SignatureDfe::SSL.config.pkey = path
		SignatureDfe::SSL.config.password  = 'mybestpass'
		SignatureDfe::SSL.config.cert = cert_path
		
		expect{SignatureDfe::SSL.test}.to raise_error(SignatureDfe::Error, "Your cert '#{cert_path}' is not a valid file")
		
	end
	it "right on set up with pkey and cert" do
		path = "./certs/key.pem"
		cert_path = "./certs/certificate.pem"
		SignatureDfe::SSL.config.pkey = path
		SignatureDfe::SSL.config.password  = 'mybestpass'
		SignatureDfe::SSL.config.cert = cert_path
		expect(SignatureDfe::SSL.test).to eq(true)
	end	
end

RSpec.describe "SignatureDfe NF-e" do
	inf_nfe = %{<infNFe Id="NFe12181004034484000140558900000060011166401389" versao="4.00"><ide><cUF>12</cUF><cNF>16640138</cNF><natOp>COMPRAS P/ INDUSTR., COMERC. OU PRESTAÇAO. DE SERVIÇO</natOp><mod>55</mod><serie>890</serie><nNF>6001</nNF><dhEmi>2018-10-30T23:31:01-05:00</dhEmi><tpNF>0</tpNF><idDest>1</idDest><cMunFG>1200401</cMunFG><tpImp>1</tpImp><tpEmis>1</tpEmis><cDV>9</cDV><tpAmb>2</tpAmb><finNFe>1</finNFe><indFinal>0</indFinal><indPres>0</indPres><procEmi>1</procEmi><verProc>2.00</verProc></ide><emit><CNPJ>04034484000140</CNPJ><xNome>THIAGO FEITOSA DE SOUZA</xNome><enderEmit><xLgr>RUA BEIJA FLOR</xLgr><nro>999</nro><xBairro>DOCA FURTADO</xBairro><cMun>1200401</cMun><xMun>RIO BRANCO</xMun><UF>AC</UF><CEP>99999999</CEP></enderEmit><IE>0100000100117</IE><CRT>3</CRT></emit><avulsa><CNPJ>04034484000140</CNPJ><xOrgao>SECRETARIA DE ESTADO DA FAZENDA</xOrgao><matr>99999999</matr><xAgente>SEFAZNET.AC.GOV.BR</xAgente><UF>AC</UF><nDAR>0</nDAR><dEmi>2018-10-30</dEmi><repEmi>ATENDIMENTO - SEFAZ</repEmi></avulsa><dest><CNPJ>04034484000140</CNPJ><xNome>NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL</xNome><enderDest><xLgr>RUA RIO DE JANEIRO</xLgr><nro>1245</nro><xBairro>FLORESTA</xBairro><cMun>1200807</cMun><xMun>PORTO ACRE</xMun><UF>AC</UF><CEP>69914180</CEP></enderDest><indIEDest>1</indIEDest><IE>0100000100117</IE></dest><det nItem="1"><prod><cProd>FOXUCJKYANUR</cProd><cEAN/><xProd>VNIQCUZMBXGEMRYXOGAGMCYXUCLAFUCXD</xProd><NCM>11010010</NCM><CFOP>1101</CFOP><uCom>KG</uCom><qCom>3291.614</qCom><vUnCom>727.47</vUnCom><vProd>2394550.43</vProd><cEANTrib/><uTrib>KG</uTrib><qTrib>3291.614</qTrib><vUnTrib>727.47</vUnTrib><indTot>1</indTot></prod><imposto><ICMS><ICMS00><orig>0</orig><CST>00</CST><modBC>3</modBC><vBC>2394550.43</vBC><pICMS>8.30</pICMS><vICMS>198747.68</vICMS></ICMS00></ICMS><PIS><PISAliq><CST>01</CST><vBC>0.00</vBC><pPIS>0</pPIS><vPIS>0</vPIS></PISAliq></PIS><COFINS><COFINSAliq><CST>01</CST><vBC>0.00</vBC><pCOFINS>0.00</pCOFINS><vCOFINS>0.00</vCOFINS></COFINSAliq></COFINS></imposto></det><det nItem="2"><prod><cProd>ICHGIJHYQYQKUSIAQAAYUKZISVDQHYADDGDHVJ</cProd><cEAN/><xProd>PUEVPPKYQYATSWLNIJQQI</xProd><NCM>11010010</NCM><CFOP>1101</CFOP><uCom>KG</uCom><qCom>2141.194</qCom><vUnCom>482.64</vUnCom><vProd>1033425.87</vProd><cEANTrib/><uTrib>KG</uTrib><qTrib>2141.194</qTrib><vUnTrib>482.64</vUnTrib><indTot>1</indTot></prod><imposto><ICMS><ICMS00><orig>0</orig><CST>00</CST><modBC>3</modBC><vBC>1033425.87</vBC><pICMS>2.56</pICMS><vICMS>26455.70</vICMS></ICMS00></ICMS><PIS><PISAliq><CST>01</CST><vBC>0.00</vBC><pPIS>0</pPIS><vPIS>0</vPIS></PISAliq></PIS><COFINS><COFINSAliq><CST>01</CST><vBC>0.00</vBC><pCOFINS>0.00</pCOFINS><vCOFINS>0.00</vCOFINS></COFINSAliq></COFINS></imposto></det><det nItem="3"><prod><cProd>JFIOXKPQYNTDZEITQANODGGIASB</cProd><cEAN/><xProd>OLPOTCGOKQOQEDPJQUTHWNSOAEMFMSXWBC</xProd><NCM>11010010</NCM><CFOP>1101</CFOP><uCom>KG</uCom><qCom>3063.445</qCom><vUnCom>867.24</vUnCom><vProd>2656742.04</vProd><cEANTrib/><uTrib>KG</uTrib><qTrib>3063.445</qTrib><vUnTrib>867.24</vUnTrib><indTot>1</indTot></prod><imposto><ICMS><ICMS00><orig>0</orig><CST>00</CST><modBC>3</modBC><vBC>2656742.04</vBC><pICMS>7.06</pICMS><vICMS>187565.98</vICMS></ICMS00></ICMS><PIS><PISAliq><CST>01</CST><vBC>0.00</vBC><pPIS>0</pPIS><vPIS>0</vPIS></PISAliq></PIS><COFINS><COFINSAliq><CST>01</CST><vBC>0.00</vBC><pCOFINS>0.00</pCOFINS><vCOFINS>0.00</vCOFINS></COFINSAliq></COFINS></imposto></det><det nItem="4"><prod><cProd>EQSXOOOZYSJXWZIHNBKZ</cProd><cEAN/><xProd>DTGRJPWHSADWUB</xProd><NCM>11010010</NCM><CFOP>1101</CFOP><uCom>KG</uCom><qCom>4685.234</qCom><vUnCom>566.77</vUnCom><vProd>2655450.07</vProd><cEANTrib/><uTrib>KG</uTrib><qTrib>4685.234</qTrib><vUnTrib>566.77</vUnTrib><indTot>1</indTot></prod><imposto><ICMS><ICMS00><orig>0</orig><CST>00</CST><modBC>3</modBC><vBC>2655450.07</vBC><pICMS>2.52</pICMS><vICMS>66917.34</vICMS></ICMS00></ICMS><PIS><PISAliq><CST>01</CST><vBC>0.00</vBC><pPIS>0</pPIS><vPIS>0</vPIS></PISAliq></PIS><COFINS><COFINSAliq><CST>01</CST><vBC>0.00</vBC><pCOFINS>0.00</pCOFINS><vCOFINS>0.00</vCOFINS></COFINSAliq></COFINS></imposto></det><det nItem="5"><prod><cProd>CKAXYESMPACIEEKKCQTDUOB</cProd><cEAN/><xProd>TXZZGSAL</xProd><NCM>11010010</NCM><CFOP>1101</CFOP><uCom>KG</uCom><qCom>4944.379</qCom><vUnCom>348.80</vUnCom><vProd>1724599.39</vProd><cEANTrib/><uTrib>KG</uTrib><qTrib>4944.379</qTrib><vUnTrib>348.80</vUnTrib><indTot>1</indTot></prod><imposto><ICMS><ICMS00><orig>0</orig><CST>00</CST><modBC>3</modBC><vBC>1724599.39</vBC><pICMS>8.90</pICMS><vICMS>153489.34</vICMS></ICMS00></ICMS><PIS><PISAliq><CST>01</CST><vBC>0.00</vBC><pPIS>0</pPIS><vPIS>0</vPIS></PISAliq></PIS><COFINS><COFINSAliq><CST>01</CST><vBC>0.00</vBC><pCOFINS>0.00</pCOFINS><vCOFINS>0.00</vCOFINS></COFINSAliq></COFINS></imposto></det><total><ICMSTot><vBC>10464767.80</vBC><vICMS>633176.04</vICMS><vICMSDeson>0</vICMSDeson><vFCP>0</vFCP><vBCST>0.00</vBCST><vST>0.00</vST><vFCPST>0</vFCPST><vFCPSTRet>0</vFCPSTRet><vProd>10464767.80</vProd><vFrete>0</vFrete><vSeg>0</vSeg><vDesc>0</vDesc><vII>0</vII><vIPI>0</vIPI><vIPIDevol>0</vIPIDevol><vPIS>0</vPIS><vCOFINS>0</vCOFINS><vOutro>0</vOutro><vNF>10464767.80</vNF></ICMSTot></total><transp><modFrete>9</modFrete></transp><pag><detPag><tPag>90</tPag><vPag>0</vPag></detPag></pag><infAdic><infAdFisco>ESTA NOTA FISCAL AVULSA DEVE OBRIGATORIAMENTE ESTAR ACOMPANHADA DO DOCUMENTO DE ARRECADAÇÃO PAGO.</infAdFisco></infAdic></infNFe>}

	signature_value = ""
	x509certificate = ""
	digest_value = ""
	ch_nfe = "12181004034484000140558900000060011166401389"

	it "calc digest" do		
		expect(SignatureDfe::NFe.digest_value inf_nfe).to eq("zW0EdR3pXLdRTGFWvPOoqCNYnp8=")
	end

	it "gen signature_value" do
		digest_value = "zW0EdR3pXLdRTGFWvPOoqCNYnp8="
		signature_value = SignatureDfe::NFe.signature_value ch_nfe, digest_value
		expect(signature_value).to eq("QGa8P3ny6xanGkAgfsTpU0SCkZ+0nlpgYiBhVnOmH7wdFRqttJpjdKYr82qm\nd4vdRCXdbEwEwlaWbSiKpEFfn+dBNNiXeLsnNYTij/tPno0xbBVVZ+AV+SDA\nJMKJ0HqaIvkBvfkBwRtB6fekajJJK+d40jJdCozLbQ4wIy16v6l6ZHxYuz4k\np1vfm8ojPI2+Gn1M7UidCsbJmf+f1pyfMI0Bw2IfwAR7VYK2dEXaegjMyvQ1\ns7RasNCjjpMvQZEAWHDOsctt4m58va+Z0n2Wys0zW213Jz9vaZbQRJZDBx43\nnTnteWGdwawIMj2REmfVjUgTxLevUDwiKoXj9fdXWw==")
	end

	it "X509Certificate" do
		x509certificate = File.read("./certs/certificate.pem").gsub(/\-\-\-\-\-[A-Z]+ CERTIFICATE\-\-\-\-\-/, "").strip
		expect(SignatureDfe::SSL.cert).to eq(x509certificate)
	end

	it "full signature" do
		full_signature = "<Signature xmlns=\"http://www.w3.org/2000/09/xmldsig#\"><SignedInfo><CanonicalizationMethod Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/><SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#rsa-sha1\"/><Reference URI=\"#NFe12181004034484000140558900000060011166401389\"><Transforms><Transform Algorithm=\"http://www.w3.org/2000/09/xmldsig#enveloped-signature\"/><Transform Algorithm=\"http://www.w3.org/TR/2001/REC-xml-c14n-20010315\"/></Transforms><DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/><DigestValue>zW0EdR3pXLdRTGFWvPOoqCNYnp8=</DigestValue></Reference></SignedInfo><SignatureValue>#{signature_value}</SignatureValue><KeyInfo><X509Data><X509Certificate>#{x509certificate.strip}</X509Certificate></X509Data></KeyInfo></Signature>"
		expect(SignatureDfe::NFe.sign inf_nfe).to eq(full_signature)
	end
end
