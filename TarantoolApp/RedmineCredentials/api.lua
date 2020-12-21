local RedmineCredentials=box.space.RedmineCredentials

function AddRedmineCredentials(Session,Url,Login,Password)
  return RunWithUser(Session,function(User)
    local request_result=RedmineConnectionTest(Url,Login,Password)
    if request_result.status<300 and request_result.status>199 then
      local Result
      if pcall(function()
            Result=RedmineCredentials:insert{nil,User[1],Url,Login,Password}
          end) then
        return 200,{NewID=Result[1]}
      else
        return 409
      end
    else
      return 403,{request_result=request_result}
    end
  end)
end

function GetRedmineCredentialsList(Session)
  return RunWithUser(Session,function(User)
    local Result={}
    for _,i in RedmineCredentials.index.Owner:pairs(User[1]) do
      Result[#Result+1]={ID=i[1],OwnerID=i[2],Url=i[3],Login=i[4],Password=i[5]}
    end
    if #Result==0 then
      Result='[]'
    end
    return 200,Result
  end)
end
