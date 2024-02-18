WiJungle-SVNIT

Everytime user logs-in, the web sends a POST API request which authenticates the request
And every 50msec (approx) this connection is renewed

Below is the POST Request information of the initial commection request :

General Header : 
```
Request URL:
https://172.16.1.1:8090/index.php?pageto=c&ms=ds78asdasd444b6rasda3&mes=ds78asdasd444b6rasda3
Request Method:
POST
Status Code:
200 OK
Remote Address:
172.16.1.1:8090
Referrer Policy:
strict-origin-when-cross-origin
```

Request Headers:
```
POST /index.php?pageto=c&ms=ds78asdasd444b6rasda3&mes=ds78asdasd444b6rasda3 HTTP/1.1
Accept: application/json, text/plain, */*
Accept-Encoding: gzip, deflate, br
Accept-Language: en-US,en;q=0.9
Connection: keep-alive
Content-Length: 65
Content-Type: application/x-www-form-urlencoded
Host: 172.16.1.1:8090
Origin: https://172.16.1.1:8090
Referer: https://172.16.1.1:8090/
Sec-Fetch-Dest: empty
Sec-Fetch-Mode: cors
Sec-Fetch-Site: same-origin
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36
```

Payload:
```
Form Data:
"fixeduserid": $USERNAME,
"loginMethod": "6",
"password": $PASSWORD,
"portal": "1",
"stage": "9"
```

Responses from various requests :

Login Request : 
Response : {"status":"success","data":{"stage":"6","userid":xxxx,"username":"u21csxxx","k1":xxxxxxxxxxx}}

Keep-alive Request :
Response : {"status":"success"}

Logout Request :
Response : Success

