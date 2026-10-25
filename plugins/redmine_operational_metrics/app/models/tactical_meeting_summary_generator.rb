require 'net/http'
require 'json'

class TacticalMeetingSummaryGenerator
  class Error < StandardError; end

  REVIEWS_INPUT = 'TextInput-lDuqN'
  ITEMS_INPUT = 'TextInput-t60sl'

  def initialize(tactical_meeting)
    @tactical_meeting = tactical_meeting
  end

  def reviews_rows
    @reviews_rows ||= view_rows('vw_tactical_meeting_reviews')
  end

  def items_rows
    @items_rows ||= view_rows('vw_tactical_meeting_review_items')
  end

  def generate
    flow_id = ENV['LANGFLOW_FLOW_ID']
    api_key = ENV['LANGFLOW_API_KEY']
    raise Error, 'LANGFLOW_FLOW_ID / LANGFLOW_API_KEY are not configured.' if flow_id.blank? || api_key.blank?

    base_url = ENV['LANGFLOW_URL'].presence || 'https://langflow.itjl.xyz'
    uri = URI("#{base_url}/api/v1/run/#{flow_id}?stream=false")
    body = {
      input_value: 'run',
      tweaks: {
        REVIEWS_INPUT => { input_value: reviews_rows.to_json },
        ITEMS_INPUT => { input_value: items_rows.to_json }
      }
    }

    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json', 'x-api-key' => api_key)
    request.body = body.to_json

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', open_timeout: 30, read_timeout: 600) do |http|
      http.request(request)
    end
    raise Error, "Langflow returned HTTP #{response.code}: #{response.body.to_s[0, 300]}" unless response.is_a?(Net::HTTPSuccess)

    text = JSON.parse(response.body).dig('outputs', 0, 'outputs', 0, 'results', 'message', 'text')
    raise Error, 'Langflow returned an empty summary.' if text.blank?

    text
  rescue JSON::ParserError, SocketError, SystemCallError, Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError => e
    raise Error, "Langflow request failed: #{e.message}"
  end

  private

  def view_rows(view_name)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, ["SELECT * FROM #{view_name} WHERE meeting_id = ?", @tactical_meeting.id])
    ActiveRecord::Base.connection.select_all(sql).to_a
  end
end
