# Google Authenticator resource for MTA

2FA Resource using google authenticator!

# Client

Draw qr code!

```lua
bool dxDrawGAuth( number x, number y, number width, number height )
```

# Server

Download QR Code for player, to use dxDrawGAuth!

```lua
startDownloadGAuth( element player )
```

Validate code from authenticator!

```lua
bool validateGAuthCode( element player, string code )
```