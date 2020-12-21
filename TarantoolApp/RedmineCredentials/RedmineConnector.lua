local digest=require('digest')
local http_client=require('http.client').new({max_connections=5000})
local json=require('json')

local RedmineCredentials=box.space.RedmineCredentials

function RedmineConnectionTest(Url,Login,Password)
  return http_client:get(Url..'/projects.xml',{headers={Authorization='Basic '..digest.base64_encode(Login..':'..Password)}})
end

function RedmineRequest(RedmineCredentialID,UserID,Url,callback,params,limit,offset)
  local RC=RedmineCredentials:get(RedmineCredentialID)
  if RC then
    if UserID==RC[2] then
      local RequestParams=(limit and '&limit='..tostring(limit) or '')..(offset and '&offset='..tostring(offset) or '')
      for k,v in pairs(params or {}) do
        RequestParams=RequestParams..'&'..k..'='..v
      end
      if #RequestParams>0 then
        RequestParams='?'..RequestParams:sub(2)
      end
      return callback(http_client:get(RC[3]..Url..RequestParams,
        {headers={Authorization='Basic '..digest.base64_encode(RC[4]..':'..RC[5]),['Content-Type']='application/json'}}))
    else
      return 403,{error='you are not owner'}
    end
  else
    return 404,{error='invalid RedmineCredentialID'}
  end
end

function RunWithRedmineRequest(Session,CredID,Url,callback,params,limit,offset)
  return RunWithUser(Session,function(User)
    return RedmineRequest(CredID,User[1],Url,function(Res)
        local JRes
        if Res.status<300 and Res.status>199 and pcall(function()
              JRes=json.decode(Res.body)
            end) then
          return callback(User,Res.status,JRes)
        else
          return 500,{error='redmine error'}
        end
      end,params,limit,offset)
  end)
end
