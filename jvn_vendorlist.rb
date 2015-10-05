require "net/http"
require "uri"
require "rexml/document"


def parameterize(params)
  params.map{|k,v| "#{k}=#{v}"}.join('&')
end


def get_vendor_list(start_item)
  params = {
    method: 'getVendorList',
    startItem: start_item
  }

  result = {}
  uri = URI("http://jvndb.jvn.jp/myjvn?" + parameterize(params))
  response = Net::HTTP.get_response(uri)
  if response.code == "200"
    doc = REXML::Document.new(response.body)
    status = doc.elements['Result/status:Status']
    total_res_ret = status.attributes["totalResRet"].to_i
    total_res = status.attributes["totalRes"].to_i
    
    if total_res > start_item.to_i + total_res_ret
      result = result.merge(get_vendor_list(total_res_ret + start_item.to_i))
    end

    doc.elements.each('Result/VendorInfo/Vendor') do |val|
      result[val.attributes["vid"]] = {}
      result[val.attributes["vid"]]["vname"] = val.attributes["vname"]
      result[val.attributes["vid"]]["cpe"] = val.attributes["cpe"]
    end
   
  else
    puts response.code
  end

  return result

end

vendorlist = get_vendor_list(1)
puts vendorlist["3"]["vname"]
puts vendorlist["3"]["cpe"]
