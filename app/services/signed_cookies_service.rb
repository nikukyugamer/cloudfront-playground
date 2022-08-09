require 'open-uri'

class SignedCookiesService
  attr_reader :cookie_params

  def initialize
    private_key_path = Rails.root.join('config/cloudfront_private_key.pem')

    File.write(private_key_path, ENV.fetch('CLOUDFRONT_PRIVATE_KEY')) unless File.exist?(private_key_path)

    signer = Aws::CloudFront::CookieSigner.new(
      key_pair_id: ENV.fetch('CLOUDFRONT_PUBLIC_KEY'),
      private_key_path: Rails.root.join('config/cloudfront_private_key.pem').to_s
    )

    policy_statement = {
      'Statement' => [
        {
          'Resource' => 'http*://assets.neo-kobe-city.com/*',
          'Condition' => {
            DateLessThan: {
              'AWS:EpochTime' => 5.minutes.since.to_i
            }
          }
          # "IpAddress" => {
          #   "AWS:SourceIp" => "#{request.remote_ip}/32"
          # }
        },
      ]
    }

    @cookie_params = signer.signed_cookie(
      'https://assets.neo-kobe-city.com',
      policy: policy_statement.to_json
    )
  end

  def request(path='/min_tobus2.jpg')
    http = Net::HTTP.new('assets.neo-kobe-city.com', 443)
    http.use_ssl = true
    cookies_text = @cookie_params.map { |param| param.join('=') }.join('; ')

    http.get(
      path,
      { 'Cookie' => cookies_text }
    )
  end
end
