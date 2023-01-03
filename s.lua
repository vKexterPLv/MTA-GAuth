local tokens = {}

function startDownloadGAuth(plr)
	uri = getElementData(plr,"player:gauthuri") or "https://www.authenticatorapi.com/pair.aspx?AppName=FuturityRPG&AppInfo="..getPlayerName(plr).."&SecretCode="..getPlayerSerial(plr)
	fetchRemote(uri,{},function(e,r)
		if not getElementData(plr,"player:gauthuri") then
			setElementData(plr,"player:gauthuri",uri)
		end
		im = split(e,"'")[6]
		tokens[plr] = split(im,"%")[7]:sub(3)
		fetchRemote(im,{},function(pix)
			triggerClientEvent("gotAuthIm",resourceRoot,pix,plr)
		end)
	end)
end

function validateGAuthCode(plr,pin)
	totpCode = generateTotpCode( tokens[plr], os.time() )
	if tonumber(totpCode) == tonumber(pin) then return true end
	return false
end

addEventHandler("onPlayerEnterGame",root,function(plr)
	startDownloadGAuth(plr)
end)

addEventHandler("onResourceStart",resourceRoot,function()
	for k,v in pairs(getElementsByType("player")) do
		startDownloadGAuth(v)
	end
end)

addCommandHandler("pin",function(plr,cmd,pin)
	tr = validateGAuthCode(plr,pin)
	if tr then
		outputChatBox(getPlayerName(plr)..": "..pin.." [POPRAWNY!]")
	else
		outputChatBox(getPlayerName(plr)..": "..pin.." [NIE POPRAWNY!]")
	end
end)