set $response_body ''; 

local apicast = require('apicast').new()

local setmetatable = setmetatable

local _M = require('apicast.policy').new('Example', '0.1')
local mt = { __index = _M }

function _M.new()
  return setmetatable({}, mt)
end

function _M:init()
  -- do work when nginx master process starts
end

function _M:init_worker()
  -- do work when nginx worker process is forked from master
end

function _M:rewrite()
  -- change the request before it reaches upstream
end

function _M:access()
  -- ability to deny the request before it is sent upstream
end

function _M:content()
  -- can create content instead of connecting to upstream
end

function _M:post_action()
  -- do something after the response was sent to the client
end

function _M:header_filter()
  -- can change response headers
end

function _M.body_filter()
    local resp_body = string.sub(ngx.arg[1], 1, 1000)
    ngx.ctx.buffered = string.sub((ngx.ctx.buffered or "") .. resp_body, 1, 1000)
    if ngx.arg[2] then
      ngx.var.response_body = ngx.ctx.buffered
      ngx.var.response_body = string.upper(ngx.var.response_body)
end

function _M:log()
  -- can do extra logging
end

function _M:balancer()
  -- use for example require('resty.balancer.round_robin').call to do load balancing
end

return _M
