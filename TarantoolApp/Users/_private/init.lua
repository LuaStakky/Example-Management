box.once("Users.schema",function()
  Users=box.schema.space.create('Users',{engine="vinyl",format={
    {name='ID',type='unsigned'},
    {name='Name',type='string'},
    {name='Email',type='string'},
    {name='Password',type='string'},
    {name='Type',type='string',is_nullable=true},  --Admin|Test|nil
    {name='Enabled',type='boolean'},
    {name='Session',type='string',is_nullable=true},
    --unsigned|string|integer|number|boolean|array|scalar
  }})
  box.schema.sequence.create('UsersSeq')
  Users:create_index('primary',{unique=true,parts={{1,"unsigned"}},sequence='UsersSeq'})
  Users:create_index('Login',{unique=true,parts={{3,"string"},{4,"string"}}})
  Users:create_index('Email',{unique=true,parts={{3,"string"}}})
  Users:create_index('Session',{unique=true,parts={{7,"string"}}})

  Users:insert({nil,'root','examlpe@examlpe.com',CryptoPassword('toor'),'UberAdmin',true,nil})
end)
