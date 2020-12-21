local base58=require("base58")
local digest=require('digest')
local clock=require('clock')


--Some crypto functions
local Salt=tostring(clock.time64())
function MkSession()
  return base58.encode_base58(digest.sha512(tostring(clock.time64())..Salt))
end
function CryptoPassword(Password)
  return digest.sha512(Password..'-ad2d7bbfc179aa49747e9db65dfcb9e2892110f85b492f0f5ba8a3560fe8c5e228c6910e38b08a1a299ee1d6fd6abab60fc0e293fe9c8e94e788bffb41f7217f')
end