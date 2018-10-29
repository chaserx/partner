module DiaperBankClient
  def self.post(partner_id)
    return if Rails.env != "production"

    partner = { partner:
      { diaper_partner_id: partner_id} }

    uri = URI(ENV["DIAPERBANK_APPROVAL_URL"])
    req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    req.body = partner.to_json
    req["Content-Type"] = "application/json"
    req["X-Api-Key"] = ENV["DIAPERBANK_KEY"]

    response = https(uri).request(req)

    response.body
  end

  def self.request_submission_post(partner_request_id)
    return if Rails.env != "production"
    return unless PartnerRequest.exists?(partner_request_id)

    uri = URI(ENV["DIAPERBANK_PARTNER_REQUEST_URL"])
    req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    req.body = PartnerRequestBlueprint.render(PartnerRequest.find(partner_request_id))
    req["Content-Type"] = "application/json"
    req["X-Api-Key"] = ENV["DIAPERBANK_KEY"]

    response = https(uri).request(req)

    response.body
  end

  def self.https(uri)
    Net::HTTP.new(uri.host, uri.port).tap do |http|
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end
end
