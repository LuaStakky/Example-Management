local http_client=require('http.client').new({max_connections=5000})
local json=require('json')

function GetConversionToCurrency(Currency)
  local Request=http_client:get('https://api.exchangeratesapi.io/latest?base='..Currency)
  local Result
  if Request.status<300 and Request.status>199 then
    pcall(function() Result=json.decode(Request.body).rates end)
  end
  return Request.status,Result
end