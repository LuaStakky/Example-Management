local RedmineReports=box.space.RedmineReports


function GenAndSaveReport(Session,ProjectID,ResultCurrency,DefaultHoursPerIssue,DefaultHourlyPayment,DefaultPaymentCurrency)
  local Result
  local Code,Data=GenReport(Session,ProjectID,ResultCurrency,DefaultHoursPerIssue,DefaultHourlyPayment,DefaultPaymentCurrency)
  if Code>199 and Code<300 then
    Result=RedmineReports:insert({nil,ProjectID,os.time(os.date("!*t")),Data})
  end
  return Code,{ID=Result[1],Date=os.date("!%Y-%m-%dT%TZ",Result[3])}
end



function GetReportsList(Session,ProjectID)
  return RunWithUser(Session,function(User)
    local RP=box.space.RedmineProjects:get(ProjectID)
    if RP then
      local RC=box.space.RedmineCredentials:get(RP[2])
      if RC then
        if User[1]==RC[2] then
          local Result={}
          for _,i in RedmineReports.index.RedmineProjectID:pairs({ProjectID}) do
            Result[#Result+1]={
              ID=i[1],
              Date=os.date("!%Y-%m-%dT%TZ",i[3])
            }
          end
          return 200,Result
        else
          return 403,{error='you are not owner'}
        end
      else
        return 404,{error='invalid CredentialID'}
      end
    else
      return 404,{error='invalid ProjectID'}
    end
  end)
end

function GetReport(Session,ID)
  return RunWithUser(Session,function(User)
      local Report=RedmineReports:get(ID)
    local RP=box.space.RedmineProjects:get(Report[2])
    if RP then
      local RC=box.space.RedmineCredentials:get(RP[2])
      if RC then
        if User[1]==RC[2] then
          return 200,Report[4]
        else
          return 403,{error='you are not owner'}
        end
      else
        return 404,{error='invalid RedmineCredentialID'}
      end
    else
      return 500
    end
  end)
end