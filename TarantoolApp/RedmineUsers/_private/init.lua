box.once("RedmineUsers.schema",function()
  RedmineUsers=box.schema.space.create('RedmineUsers',{engine="vinyl",format={
    {name='ID',type='unsigned'},
    {name='Credentials',type='unsigned'},
    {name='RedmineID',type='unsigned'},
    {name='WasRemovedFromRedmine',type='boolean'},
    {name='Type',type='string'},--User|Group
    {name='SalaryPerHour',type='double',is_nullable=true},
    {name='SalaryPerHourCurrency',type='string',is_nullable=true},
    {name='Country',type='string',is_nullable=true}
  }})
  box.schema.sequence.create('RedmineUsersSeq')
  RedmineUsers:create_index('primary',{unique=true,parts={{1,"unsigned"}},sequence='RedmineUsersSeq'})
  RedmineUsers:create_index('Credentials',{unique=false,parts={{2,"unsigned"}}})
  RedmineUsers:create_index('RedmineID',{unique=true,parts={{2,"unsigned"},{3,"unsigned"}}})
end)