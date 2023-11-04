require "jwt"
require "net/http"

module FirebaseAuth
  ISSUER_PREFIX = "https://securetoken.google.com/".freeze
  ALGORITHM = "RS256".freeze

  FIREBASE_PROJECT_ID = ENV["FIREBASE_PROJECT_ID"]

  CERT_URI =
    "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com".freeze

  def verify_id_token(id_token)
    payload, header = decode_unverified(id_token)
    public_key = get_public_key(header)

    errors = verify(id_token, public_key)

    if errors.empty?
      return { uid: payload["user_id"], name: payload["name"] }
    else
      return { errors: errors.join(" / ") }
    end
  end

  private

  def decode_unverified(token)
    decode_token(
      token: token,
      key: nil,
      verify: false,
      options: {
        algorithm: ALGORITHM,
      },
    )
  end

  def decode_token(token:, key:, verify:, options:)
    JWT.decode(token, key, verify, options)
  end

  def get_public_key(header)
    certificate = find_certificate(header["kid"])
    public_key = OpenSSL::X509::Certificate.new(certificate).public_key
  rescue OpenSSL::X509::CertificateError => e
    raise "Invalid certificate. #{e.message}"

    return public_key
  end

  def find_certificate(kid)
    certificates = fetch_certificates
    unless certificates.keys.include?(kid)
      raise "Invalid 'kid', do not correspond to one of valid public keys."
    end

    valid_certificate = certificates[kid]
    return valid_certificate
  end

  def fetch_certificates
    uri = URI.parse(CERT_URI)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    req = Net::HTTP::Get.new(uri.path)
    res = https.request(req)
    unless res.code == "200"
      raise "Error: can't obtain valid public key certificates from Google."
    end

    certificates = JSON.parse(res.body)
    return certificates
  end

  def verify(token, key)
    errors = []

    begin
      decoded_token =
        decode_token(
          token: token,
          key: key,
          verify: true,
          options: decode_options,
        )
    rescue JWT::ExpiredSignature
      errors << "Firebase ID token has expired. Get a fresh token from your app and try again."
    rescue JWT::InvalidIatError
      errors << "Invalid ID token. 'Issued-at time' (iat) must be in the past."
    rescue JWT::InvalidIssuerError
      errors << "Invalid ID token. 'Issuer' (iss) Must be 'https://securetoken.google.com/<firebase_project_id>'."
    rescue JWT::InvalidAudError
      errors << "Invalid ID token. 'Audience' (aud) must be your Firebase project ID."
    rescue JWT::VerificationError => e
      errors << "Firebase ID token has invalid signature. #{e.message}"
    rescue JWT::DecodeError => e
      errors << "Invalid ID token. #{e.message}"
    end

    sub = decoded_token[0]["sub"]
    alg = decoded_token[1]["alg"]

    unless sub.is_a?(String) && !sub.empty?
      errors << "Invalid ID token. 'Subject' (sub) must be a non-empty string."
    end

    unless alg == ALGORITHM
      errors << "Invalid ID token. 'alg' must be '#{ALGORITHM}', but got #{alg}."
    end

    return errors
  end

  def decode_options
    {
      iss: ISSUER_PREFIX + FIREBASE_PROJECT_ID,
      aud: FIREBASE_PROJECT_ID,
      algorithm: ALGORITHM,
      verify_iat: true,
      verify_iss: true,
      verify_aud: true,
    }
  end
end