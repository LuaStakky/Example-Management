local RedmineProjects=box.space.RedmineProjects

function RedmineProjectsSync(Session,CredID)
  return RunWithRedmineRequest(Session,CredID,'/projects.json',function(User,Status,Json)
    local IDs={}
    local InvalidIDs={}
    for _,i in pairs(Json.projects) do
      IDs[i.id]=true
    end
    for _,i in RedmineProjects.index.RedmineID:pairs({CredID},{iterator = "EQ"}) do
      if i[4] and IDs[i[3]] then
        IDs[i[3]]=nil
      else
        InvalidIDs[#InvalidIDs+1]=i[3]
      end
    end
    for _,i in pairs(InvalidIDs) do
      RedmineProjects.index.RedmineID:update({CredID,i}, {{'=', 4, true}})
    end
    for i,actual in pairs(IDs) do
      if actual then
        RedmineProjects:insert({nil,CredID,i,false})
      end
    end
    return 200
  end,nil,1000)
end

function RedmineProjectsList(Session,CredID)
  return RunWithRedmineRequest(Session,CredID,'/projects.json',function(User,Status,Json)
    local MappedData={}
    local Result={}
    for _,i in pairs(Json.projects) do
      MappedData[i.id]=i
    end
    for _,i in RedmineProjects.index.RedmineID:pairs({CredID},{iterator = "EQ"}) do
      Result[#Result+1]={ID=i[1],RedmineID=i[3],Name=MappedData[i[3]].name,WasRemovedFromRedmine=i[4]}
    end
    return 200,Result
  end,nil,1000)
end