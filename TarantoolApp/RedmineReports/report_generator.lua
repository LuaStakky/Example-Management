local etlua=require('etlua')
local log=require('log')
local json=require('json')

local report_template=etlua.compile(preloaded_data.report_template)

function GenReport(Session,ProjectID,ResultCurrency,DefaultHoursPerIssue,DefaultHourlyPayment,DefaultPaymentCurrency)
  local RedmineProjectID

  local Code,CurrencyConversions=GetConversionToCurrency(ResultCurrency or 'USD')
  if not CurrencyConversions and Code>199 and Code<300 then
    return 500,{error='Error when get currency conversions'}
  end

  local CredID=box.space.RedmineProjects:get(ProjectID)[2]

  if pcall(function() RedmineProjectID=box.space.RedmineProjects:get(ProjectID)[3] end)then
    return RunWithRedmineRequest(Session,CredID,'/issues.json',function(User,Status,Json)
      local IssuesByWorker={}
      for _,i in pairs(Json.issues) do
        local CurrWorker
        if i.assigned_to and i.assigned_to.id then
          CurrWorker=i.assigned_to.id
        else
          CurrWorker=-1
        end
        if not IssuesByWorker[CurrWorker] then
          IssuesByWorker[CurrWorker]={}
        end
        IssuesByWorker[CurrWorker][#(IssuesByWorker[CurrWorker])+1]=i
      end

      local Workers={}
      for WorkerID,_ in pairs(IssuesByWorker) do
        if WorkerID~=-1 then
          local Worker=box.space.RedmineUsers.index.RedmineID:select({CredID,WorkerID})
          if #Worker==0 and Worker[1][4] then
            return 426,{Error="NeedToSyncUsers"}
          else
            Worker=Worker[1]
          end
          local Status,WorkerName
          if Worker[5]=='User' then
            Status,WorkerName=RedmineRequest(CredID,User[1],'/users/'..WorkerID..'.json',function(Res)
                if Res.status<300 and Res.status>199 and pcall(function()
                      JRes=json.decode(Res.body)
                    end) then
                  return 200,JRes.user.firstname..' '..JRes.user.lastname..' @'..JRes.user.login
                else
                  return Res.status,{WorkerID=WorkerID,body=Res.body}
                end
              end)
          else
            Status,WorkerName=RedmineRequest(CredID,User[1],'/groups/'..WorkerID..'.json',function(Res)
                if Res.status<300 and Res.status>199 and pcall(function()
                      JRes=json.decode(Res.body)
                    end) then
                  return 200,'Group @'..JRes.group.name
                else
                  return Res.status,{WorkerID=WorkerID,body=Res.body}
                end
              end)
          end
          if Status>300 or Status<199 then
            return Status,WorkerName
          end
          Workers[WorkerID]={
            Name=WorkerName,
            Type=Worker[5],
            SalaryPerHour=Worker[6],
            SalaryPerHourCurrency=Worker[7],
            Country=Worker[8]
          }
        end
      end

      local Status,TimeEntries=RedmineRequest(CredID,User[1],'/time_entries.json',function(Res)
            if Res.status<300 and Res.status>199 and pcall(function()
                  JRes=json.decode(Res.body)
                end) then
              return 200,JRes.time_entries
            else
              return Res.status,{WorkerID=WorkerID,body=Res.body}
            end
          end,{project_id=RedmineProjectID},100000)
      if Status>300 or Status<199 then
        return Status,TimeEntries
      end
      local TimeEntriesByIssue={}
      for _,i in pairs(TimeEntries) do
        local CurrIssue=i.issue.id
        if not TimeEntriesByIssue[CurrIssue] then
          TimeEntriesByIssue[CurrIssue]={}
        end
        TimeEntriesByIssue[CurrIssue][#(TimeEntriesByIssue[CurrIssue])+1]=i
      end

      local env={
        IssuesByWorker=IssuesByWorker,
        Workers=Workers,
        TimeEntriesByIssue=TimeEntriesByIssue,
        Defaults={
          HoursPerIssue=DefaultHoursPerIssue or 8,
          HourlyPayment=DefaultHourlyPayment or 20,
          PaymentCurrency=DefaultPaymentCurrency or 'USD'
        },
        ResultCurrency=ResultCurrency or 'USD',
        CurrencyConversions=CurrencyConversions,
        json=json,
        round=function(x)
          return math.floor(x*1000+0.5)/1000
        end
      }
      return 200,report_template(env)
    end,{project_id=RedmineProjectID,status_id='*'},100000)
  else
    return 404,{error='Project not found'}
  end
end