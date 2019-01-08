[![Travis CI](https://travis-ci.org/thiaguerd/signature_dfe.svg?branch=master)](https://travis-ci.org/thiaguerd/signature_dfe) [![Gem Version](https://badge.fury.io/rb/signature_dfe.svg)](https://rubygems.org/gems/signature_dfe)

# SignatureDfe

 Assinatura digital de documentos fiscais eletrônicos (DF-e)


## Descrição

Assine seu DF-e de forma rápida e fácil

## Instalação

Add this line to your application's Gemfile:

```ruby
gem 'signature_dfe'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install signature_dfe

## Configurando

Você vai precisar do certificado PKCS12 ou da chave privada e o certificado público.

No caso de você ter o arquivo PKCS12

```ruby
SignatureDfe::SSL.config.pkcs12   = "caminho/para/seu/cert.p12"
SignatureDfe::SSL.config.password = "sua_senha"
```

Já se vc usa a chave privada e o certificado separado

```ruby
SignatureDfe::SSL.config.pkey      = "caminho/para/sua/chave_privada.pem"
SignatureDfe::SSL.config.password  = "sua_senha"
SignatureDfe::SSL.config.cert.     = "caminho/para/seu/certificado_publico.pem"
```

Feito esta configuração você testa, no caso de tudo certo, o resultado será true

```ruby
SignatureDfe::SSL.test
```

Feito esta configuração vc já está pronto para assinar seus documentos.

## Assinatura digital NF-e NFC-e e NFA-e 

Observe que os 3 documentos possuem a mesma estrutura

Para assinar sua nf-e existem duas formas

A forma qual vc tem a xml da assinautra completo onde vc passa o seu xml contendo a tag <b>infNFe</b>

```ruby
inf_nfe = %{
<infNFe Id="NFe00000000000000000000000000000000000000000000" versao="3.10">
	...
</infNFe>}
SignatureDfe::NFe.sign inf_nfe
```

Onde a resposta será

```xml
<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">
	<SignedInfo>
		<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
		<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>
		<Reference URI="#NFe...">
			<Transforms>
				<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
				<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
			</Transforms>
			<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>
			<DigestValue>...</DigestValue>
		</Reference>
	</SignedInfo>
	<SignatureValue>...</SignatureValue>
	<KeyInfo>
		<X509Data>
			<X509Certificate>...</X509Certificate>
		</X509Data>
	</KeyInfo>
</Signature>
```

E a forma qual onde você pode obter os valores do <b>DigestValue</b>, <b>SignatureValue</b> e <b>X509Certificate</b> manualmente, e assim montar da forma como desejar seu xml

```ruby
inf_nfe = %{
<infNFe Id="NFe00000000000000000000000000000000000000000000" versao="3.10">
	...
</infNFe>}
ch_nfe = "0000000000000000000000000000000000000000000"
digest_value = SignatureDfe::NFe.digest_value inf_nfe
signature_value = SignatureDfe::NFe.signature_value ch_nfe, digest_value
x509certificate = SignatureDfe::SSL.cert
```

## Assinatura digital Evento de NF-e NFC-e e NFA-e 

Observe que os 3 documentos possuem a mesma estrutura

Para assinar sua nf-e existem duas formas

A forma qual vc tem a xml da assinautra completo onde vc passa o seu xml contendo a tag <b>infNFe</b>

```ruby
inf_evento = %{
<infEvento Id="ID1101115515151515151515151515156546546546545646544701">
	...
</infEvento>}
SignatureDfe::NFe::Event.sign inf_evento
```

Onde a resposta será

```xml
<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">
	<SignedInfo>
		<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
		<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>
		<Reference URI="#ID1...">
			<Transforms>
				<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
				<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>
			</Transforms>
			<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>
			<DigestValue>...</DigestValue>
		</Reference>
	</SignedInfo>
	<SignatureValue>...</SignatureValue>
	<KeyInfo>
		<X509Data>
			<X509Certificate>...</X509Certificate>
		</X509Data>
	</KeyInfo>
</Signature>
```

E a forma qual onde você pode obter os valores do <b>DigestValue</b>, <b>SignatureValue</b> e <b>X509Certificate</b> manualmente, e assim montar da forma como desejar seu xml

```ruby
inf_evento = %{
<infEvento Id="ID1101115515151515151515151515156546546546545646544701">
	...
</infEvento>}
event_id = "ID1101115515151515151515151515156546546546545646544701"
digest_value = SignatureDfe::NFe::Event.digest_value inf_evento
signature_value = SignatureDfe::NFe::Event.signature_value event_id, digest_value
x509certificate = SignatureDfe::SSL.cert
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SignatureDfe project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/signature_dfe/blob/master/CODE_OF_CONDUCT.md).
