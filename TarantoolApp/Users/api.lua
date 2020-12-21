local Users=box.space.Users

function RegisterUser(UserName,Email,Password)
  local Result
  if Users.index.Email:get(Email) then
    return 409
  elseif pcall(function()
      Result=Users:insert{nil,UserName,Email,CryptoPassword(Password),nil,true,nil}
    end)then
    return 200
  else
    return 500
  end
end

function GetCurrUser(Session)
  return RunWithUser(Session,function(User)
    return 200,{
      ID=User[1],
      Name=User[2],
      Email=User[3],
      TrueUser=User[5]=='Admin' or User[5]=='UberAdmin' or User[5]=='Test',
      IsAdmin=User[5]=='Admin' or User[5]=='UberAdmin',
      IsUberAdmin=User[5]=='UberAdmin',
      Enabled=User[6],
    }
  end)
end

function Login(Email,Password)
  local Res=Users.index.Login:get({Email,CryptoPassword(Password)})
  local Session=MkSession()
  if Res and Res[6] and pcall(function()
        Users.index.Login:update({Email,CryptoPassword(Password)},{{'=',7,Session}})
      end) then
    return 200,Session
  else
    return 404
  end
end

function NewPassword(Session,OldPassword,NewPassword)
  return RunWithUser(Session,function(User)
      if User[4]==CryptoPassword(OldPassword) then
        Users:update(User[1],{{'=',4,CryptoPassword(NewPassword)}})
        return 200
      else
        return 403
      end
    end)
end