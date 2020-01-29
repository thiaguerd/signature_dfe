class BuildCerts
  def self.build(options = {})
    gen_pem(options)
    gen_pkcs12(options)
  end

  def self.gen_pem(options = {})
    cmd = [
      "openssl req -passout pass:#{options[:pass]} -newkey rsa:2048 ",
      "-keyout #{options[:key_path]} -x509 -days 365 -out ",
      "#{options[:cert_path]} -subj '/C=US/ST=New York/L=New York/O=IT/OU=Host",
      ' Team/CN=domain.com/emailAddress=your@email.com/subjectAltName=',
      "domain.com' &> /dev/null"
    ]
    `#{cmd.join('')}`
  end

  def self.gen_pkcs12(options = {})
    cmd = [
      "openssl pkcs12 -inkey #{options[:key_path]} -in ",
      "#{options[:cert_path]} -export -out #{options[:p12_path]} -passin ",
      "pass:#{options[:pass]}  -passout pass:#{options[:pass]} &> /dev/null"
    ]
    `#{cmd.join('')}`
  end
end
