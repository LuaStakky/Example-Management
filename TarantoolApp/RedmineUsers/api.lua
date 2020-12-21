local RedmineUsers=box.space.RedmineUsers
local json=require('json')
local ffi=require('ffi')
local log=require('log')

function RedmineUsersSync(Session,CredID)
  return RunWithRedmineRequest(Session,CredID,'/users.json',function(User,Status,Json)
    local IDs={}
    local InvalidIDs={}
    for _,i in pairs(Json.users) do
      IDs[i.id]='User'
    end

    local Status,Groups=RedmineRequest(CredID,User[1],'/groups.json',function(Res)
        local JRes
        if Res.status<300 and Res.status>199 and pcall(function()
              JRes=json.decode(Res.body)
            end) then
          return 200,JRes
        else
          return Res.status,Res.body
        end
      end,nil,1000)
    if Status>300 or Status<199 then
      return Status,Groups
    end
    for _,i in pairs(Groups.groups) do
      IDs[i.id]='Group'
    end

    for _,i in RedmineUsers.index.RedmineID:pairs({CredID},{iterator = "EQ"}) do
      if not(i[4] or IDs[i[3]]) then
        InvalidIDs[#InvalidIDs+1]=i[3]
      end
      IDs[i[3]]=nil
    end
    for _,i in pairs(InvalidIDs) do
      RedmineUsers.index.RedmineID:update({CredID,i}, {{'=', 4, true}})
    end
    for i,actual in pairs(IDs) do
      if actual then
        RedmineUsers:insert({nil,CredID,i,false,actual})
      end
    end
    return 200
  end,nil,1000)
end

function RedmineUsersList(Session,CredID)
  return RunWithRedmineRequest(Session,CredID,'/users.json',function(User,Status,Json)
    local MappedData={}
    local Result={}
    for _,i in pairs(Json.users) do
      MappedData[i.id]=i
    end

    local Status,Groups=RedmineRequest(CredID,User[1],'/groups.json',function(Res)
        local JRes
        if Res.status<300 and Res.status>199 and pcall(function()
              JRes=json.decode(Res.body)
            end) then
          return 200,JRes
        else
          return Res.status,Res.body
        end
      end,nil,1000)
    if Status>300 or Status<199 then
      return Status,Groups
    end
    for _,i in pairs(Groups.groups) do
      MappedData[i.id]=i
    end

    for _,i in RedmineUsers.index.RedmineID:pairs({CredID},{iterator = "EQ"}) do
      local MD=MappedData[i[3]]
      Result[#Result+1]={
        ID=i[1],
        RedmineID=i[3],
        Name=i[5]=='Group' and MD.name or MD.firstname..' '..MD.lastname,
        Login=MD.login,
        WasRemovedFromRedmine=i[4],
        Type=i[5],
        SalaryPerHour=i[6],
        SalaryPerHourCurrency=i[7],
        Country=i[8]
      }
    end
    return 200,Result
  end,nil,1000)
end

function UpdateRedmineUser(Session,ID,SalaryPerHour,SalaryPerHourCurrency,Country)
  return RunWithUser(Session,function(User)
    local RUser=RedmineUsers:get(ID)
    local RC=box.space.RedmineCredentials:get(RUser[2])
    if RC then
      if User[1]==RC[2] then
        if pcall(function()
            local UpdateData={}
            if RUser[6]~=SalaryPerHour then
              UpdateData[1]=SalaryPerHour and{'=',6,ffi.cast('double', SalaryPerHour)}or{'#',6,1}
            end
            if RUser[7]~=SalaryPerHourCurrency then
              UpdateData[#UpdateData+1]=SalaryPerHourCurrency and{'=',7,SalaryPerHourCurrency}or{'#',7,1}
            end
            if RUser[8]~=Country then
              UpdateData[#UpdateData+1]=Country and{'=',8,Country}or{'#',8,1}
            end
            RedmineUsers:update(ID,UpdateData)
          end)then
          return 200
        else
          return 400
        end
      else
        return 403,{error='you are not owner'}
      end
    else
      return 404,{error='invalid RedmineCredentialID'}
    end
  end)
end