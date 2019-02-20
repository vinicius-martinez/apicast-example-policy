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
  ngx.ctx.buffered = (ngx.ctx.buffered or "") .. ngx.arg[1]

  if ngx.arg[2] then -- EOF
    local dict = {}

    -- Gather information of the request
    local request = {}
    if ngx.var.request_body then
      if (base64_flag == 'true') then
        request["body"] = ngx.encode_base64(ngx.var.request_body)
      else
        request["body"] = ngx.var.request_body
      end
    end
    request["headers"] = ngx.req.get_headers()
    request["start_time"] = ngx.req.start_time()
    request["http_version"] = ngx.req.http_version()
    if (base64_flag == 'true') then
      request["raw"] = ngx.encode_base64(ngx.req.raw_header())
    else
      request["raw"] = ngx.req.raw_header()
    end

    request["method"] = ngx.req.get_method()
    request["uri_args"] = ngx.req.get_uri_args()
    request["request_id"] = ngx.var.request_id
    dict["request"] = request

    -- Gather information of the response
    local response = {}
    if ngx.ctx.buffered then
      if (base64_flag == 'true') then
        response["body"] = string.upper(ngx.encode_base64(ngx.ctx.buffered))
      else
        response["body"] = string.upper(ngx.ctx.buffered)
      end
    end
    response["headers"] = ngx.resp.get_headers()
    response["status"] = ngx.status
    dict["response"] = response
  end
  return apicast:body_filter()
end

function _M:log()
  -- can do extra logging
end

function _M:balancer()
  -- use for example require('resty.balancer.round_robin').call to do load balancing
end

return _M
