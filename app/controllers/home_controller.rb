require 'open-uri'

class HomeController < ApplicationController
  before_action :set_common_instance_variables
  before_action :check_or_create_cloudfront_private_key

  def direct_image_link
    cookies_str = cookies.map { |x| x.join('=') }.join('; ')

    send_file(
      OpenURI.open_uri('https://assets.neo-kobe-city.com/min_yuyake3.jpg', { 'Cookie' => cookies_str }),
      filename: 'min_yuyake3.jpg'
    )
  end

  def index; end

  def trial_a
    eat_cookies(without_subdomain: true)
  end

  def eat_cookies(without_subdomain: false)
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

    cookie_domain = if without_subdomain || params[:cookie_domain] == 'without_subdomain'
                      '.neo-kobe-city.com'
                    else
                      request.host
                    end

    cookie_params.each do |k, v|
      cookies[k] = { value: v, domain: cookie_domain }
    end
  end

  # https://koseki.hatenablog.com/entry/20070109/cookiedelete
  # https://stackoverflow.com/questions/6104090/deleting-cookies-from-a-controller
  def discard_cookies
    domains = [
      '.foo.neo-kobe-city.com',
      'foo.neo-kobe-city.com',
      '.neo-kobe-city.com',
      'neo-kobe-city.com',
      '.www.neo-kobe-city.com',
      'www.neo-kobe-city.com',
    ]

    # これでも消えない時がある
    domains.each do |domain|
      cookies.each do |k, _v|
        cookies[k.to_sym] = { value: '', domain: domain, path: '/', expires: Time.zone.at(0) }
        cookies.delete(k)
        cookies.delete(k, domain: domain, path: '/')
      end
    end
  end

  private

  def check_or_create_cloudfront_private_key
    private_key_path = Rails.root.join('config/cloudfront_private_key.pem')

    return if File.exist?(private_key_path)

    File.write(private_key_path, ENV.fetch('CLOUDFRONT_PRIVATE_KEY'))
  end

  def set_common_instance_variables
    @cookies = cookies.to_h
    @request_host = request.host

    @min_tobus2_url = 'https://assets.neo-kobe-city.com/min_tobus2.jpg'
    @min_tukimi3_url = 'https://assets.neo-kobe-city.com/min_tukimi3.jpg'
    @min_undokai1_url = 'https://assets.neo-kobe-city.com/min_undokai1.jpg'
    @min_up1_url = 'https://assets.neo-kobe-city.com/min_up1.jpg'
    @min_xmas3_url = 'https://assets.neo-kobe-city.com/min_xmas3.jpg'
    @min_yuyake3_url = 'https://assets.neo-kobe-city.com/min_yuyake3.jpg'
  end
end
