require 'open-uri'

class HomeController < ApplicationController
  before_action :check_or_create_cloudfront_private_key

  def direct_image_link
    cookies_str = cookies.map { |x| x.join('=') }.join('; ')

    send_file(
      OpenURI.open_uri('https://assets.neo-kobe-city.com/min_yuyake3.jpg', { 'Cookie' => cookies_str }),
      filename: 'min_yuyake3.jpg'
    )
  end

  def index
    @cookies = cookies.to_h
    @request_host = request.host

    @min_tobus2_url = 'https://assets.neo-kobe-city.com/min_tobus2.jpg'
    @min_tukimi3_url = 'https://assets.neo-kobe-city.com/min_tukimi3.jpg'
    @min_undokai1_url = 'https://assets.neo-kobe-city.com/min_undokai1.jpg'
    @min_up1_url = 'https://assets.neo-kobe-city.com/min_up1.jpg'
    @min_xmas3_url = 'https://assets.neo-kobe-city.com/min_xmas3.jpg'
    @min_yuyake3_url = 'https://assets.neo-kobe-city.com/min_yuyake3.jpg'
  end

  def eat_cookies
    check_or_create_cloudfront_private_key

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
              'AWS:EpochTime' => 1.minute.since.to_i
            }
          }
          # "IpAddress" => {
          #   "AWS:SourceIp" => "#{request.remote_ip}/32"
          # }
        },
      ]
    }

    cookie_params = signer.signed_cookie(
      'https://assets.neo-kobe-city.com',
      policy: policy_statement.to_json
    )

    cookie_params.each do |k, v|
      cookies[k] = case params[:cookie_domain]
                   when 'without_subdomain'
                     { value: v, domain: 'neo-kobe-city.com' }
                   when 'with_subdomain'
                     { value: v, domain: 'www.neo-kobe-city.com' }
                   else
                     { value: v }
                   end
    end
  end

  def discard_cookies
    cf_cookies_keys = [
      'CloudFront-Key-Pair-Id',
      'CloudFront-Policy',
      'CloudFront-Signature',
    ]

    cf_cookies_keys.each do |key|
      cookies.delete(key.to_sym)
    end
  end

  private

  def check_or_create_cloudfront_private_key
    private_key_path = Rails.root.join('config/cloudfront_private_key.pem')

    return if File.exist?(private_key_path)

    File.write(private_key_path, ENV.fetch('CLOUDFRONT_PRIVATE_KEY'))
  end
end
