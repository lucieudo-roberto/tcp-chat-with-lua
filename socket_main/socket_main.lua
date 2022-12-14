local socket = require("socket");

local CN_TRUE = false
local CN_ADDR = "127.0.0.1"  -- connection ip addres
local CN_PORT = 3000   -- connection port
local CN_TYPE = false  -- connection type, server:1 or client:2
local CN_NAME = "helo" -- server/user name
local CN_BUFF = {}     -- connection buffer
local SV_PKEY = false  -- server private key
local CL_PKEY = false  -- client private key

local print_help = function()
	print("\t\t lua tcp-chat v1.0.0 ")
	print(" -c : to connect at server chat")
	print(" -l : to create a server chat")
	print(" -u : to set server/client name")
	print(" -p : to set ip port ex: 127.0.0.1 3000")
	print(" -h : help \n")
end

local print_global_vars = function()
	print("ip " .. CN_ADDR)
	print("port " .. CN_PORT)
	print("type " .. CN_TYPE)
	print("name " .. CN_NAME)
end

local print_main = function()
	os.execute("clear")
	print('----- chat tcp.lua ------ ')
	for x=1,#CN_BUFF do print(CN_BUFF[x]) end
	io.write('-------------\n')
	io.write('[send,show,exit]: ')
	io.read()
end

local check_is_valid_ip = function(ip)
	if ip == false then return false end
	local a,b,c,d  = ip:match("^(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)$")
	local s = 0

	if tonumber(a) == nil or tonumber(a) < 0 or tonumber(a) > 255 then s=s+1 end  
	if tonumber(b) == nil or tonumber(b) < 0 or tonumber(b) > 255 then s=s+1 end  
	if tonumber(c) == nil or tonumber(c) < 0 or tonumber(c) > 255 then s=s+1 end  
	if tonumber(d) == nil or tonumber(d) < 0 or tonumber(d) > 255 then s=s+1 end

	if  s == 0 then return true end
	return false
end

local check_is_valid_pt = function(port)
	if port ~= nil and tonumber(port) > 1000 then return true end
	return false
end

local prepare_user_name = function(name)
	local _name = name:match("(%a+)")
	if _name ~= nil and #_name > 4 then 
		CN_NAME = _name 
		return true;
	end
	return false;  
end

local configure_arguments = function()
	for  x=1,#arg do 
		if arg[x] ~= nil then 
			if arg[x] == "-c" then CN_TYPE = 2 end -- user chose a client method
			if arg[x] == "-l" then CN_TYPE = 1 end -- user chose a server method
			if arg[x] == "-u" then 
				if arg[x+1] ~= nil then CN_NAME = arg[x+1] end
			end
			if arg[x] == "-p" then
				if arg[x+1] ~= nil then 
					CN_ADDR = arg[x+1] -- get ip anddres
					if arg[x+2] ~= nil then CN_PORT = arg[x+2] end
				end
			end
		end 
	end
	
	if check_is_valid_ip(CN_ADDR) == false then return 1 end
	if check_is_valid_pt(CN_PORT) == false then return 2 end
	if prepare_user_name(CN_NAME) == false then return 3 end
	return true
end

local cesar_cipher = function (text_raw,key,method)
	  -- method: 1:encrypt, 2:decrypt
	  local raw_output = ""
	  
	  if method == 1 then
	  	 for x=1,#text_raw do 
	  	 	local ascii_cod = string.byte(text_raw:sub(x,x))
	  	 	raw_output = raw_output..string.char(ascii_cod+key)
	  	 end 
	  end
	  
	  if method == 2 then
	  	 for x=1,#text_raw do 
	  	 	local ascii_cod = string.byte(text_raw:sub(x,x))
	  	 	raw_output = raw_output..string.char(ascii_cod-key)
	  	 end 
	  end

	  return raw_output
end

local gen_key = function()
	socket.sleep(1)
	math.randomseed(os.time())
	return math.random(1,25)
end

local server_listen = function()
	local tcp_master = socket.tcp()
	local KEY_A = gen_key() -- public key
	local KEY_B = gen_key() -- server private key
	SV_PKEY = (KEY_A+KEY_B)
	tcp_master:bind(CN_ADDR,CN_PORT)
	tcp_master:listen()
	
    while CN_TRUE == false do
    		print("listing") 
			local tcp_client,error = tcp_master:accept()
			local tcp_raw = tcp_client:receive()
			
			if tcp_raw == "hi" then 
				tcp_client:send(KEY_A)          -- send public key
				tcp_raw = tcp_client:receive()  -- get  private client key
				CL_PKEY = tonumber(tcp_raw)-KEY_B
				tcp_client:send(SV_PKEY)
  				tcp_raw = tcp_client:receive()
  				if tcp_raw == 'fn' then CN_TRUE = true end								
			end
	end
	tcp_master:close()
end 

local __MAIN__ = function()
--	if arg[1] == "-h" or #arg < 3 then print_help() return end
	
--	local arg_status = configure_arguments();

--	if arg_status ~= true then print(arg_status) end
--		print_global_vars()

--print_main()
-- print(cesar_cipher("lucieudo roberto",4,1))

server_listen()	
end


__MAIN__()
