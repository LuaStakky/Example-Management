local Users=box.space.Users

function RunWithUser(Session,CallBack)
  local User=Users.index.Session:get(Session)
  if User and User[6] then
    return CallBack(User)
  else
    return 401
  end
end

function RunWithAdmin(Session,CallBack)
  return RunWithUser(Session,function(User)
    if User[5]=='Admin' or User[5]=='UberAdmin' then
      return CallBack(User)
    else
      return 403
    end
  end)
end

function RunWithUberAdmin(Session,CallBack)
  return RunWithUser(Session,function(User)
    if User[5]=='UberAdmin' then
      return CallBack(User)
    else
      return 403
    end
  end)
end