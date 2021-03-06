local apicast = require('apicast').new()
local _M = { _VERSION = apicast._VERSION, _NAME = 'APIcast with transformation' }
local mt = { __index = setmetatable(_M, { __index = apicast }) }

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
local ctx = ngx.ctx
  if ctx.buffers == nil then
    ctx.buffers = {}
    ctx.nbuffers = 0
  end

  local data, eof = ngx.arg[1], ngx.arg[2]
  local next_idx = ctx.nbuffers + 1

  if not eof then
      if data then
    ctx.buffers[next_idx] = data
    ctx.nbuffers = next_idx
    -- Send nothing to the client yet.
    ngx.arg[1] = nil
    end
    return -- NEXT data
  elseif data then
    ctx.buffers[next_idx] = data
    ctx.nbuffers = next_idx
  end

  ngx.arg[1] = string.upper(table.concat(ngx.ctx.buffers))

  return apicast:body_filter()
end

function _M:log()
  -- can do extra logging
end

function _M:balancer()
  -- use for example require('resty.balancer.round_robin').call to do load balancing
end

return _M
