/*
* Launches a local HTTP server that delegates request to Personality Insights Service 
* Username and password need to be specified (see Development Guide for more info)
*/

// Test server port
var port = 8888

/// Prepare HTTP service
var http = require('http');
var url  = require('url');

// Current access token
var accessToken = "random_token_" + (Math.random() * 1000000)

/// Sample responses files
var folderName = 'JSON_responses'
// success responses
var filenamesByAPI = new Object();
filenamesByAPI['/oauth2'] = folderName + '/oauth2_success.json';
filenamesByAPI['/validateToken'] = folderName + '/validateToken_success.json';
filenamesByAPI['/refresh'] = folderName + '/refresh_success.json';
filenamesByAPI['/userprofile'] = folderName + '/userprofile_success.json';
filenamesByAPI['/logout'] = folderName + '/logout_success.json';
filenamesByAPI['/API/UserGetDetail'] = folderName + '/UserGetDetail_Response.json';
filenamesByAPI['/API/Profile/UserGetDetail'] = folderName + '/UserGetDetail_Response.json';
filenamesByAPI['/API/incidentGetList'] = folderName + '/incidentGetList_Response.json';
filenamesByAPI['/API/Incident/GetList'] = folderName + '/incidentGetList_Response.json';
filenamesByAPI['/API/incidentGetWorkInfo'] = folderName + '/incidentGetWorkInfo_Response.json';
filenamesByAPI['/API/IncidentCreate'] = folderName + '/IncidentCreate_response.json';

// error responses
var errorFilenamesByAPI = new Object();
errorFilenamesByAPI['/oauth2?showError=yes'] = folderName + '/oauth2_error.json';
errorFilenamesByAPI['/validateToken?showError=yes'] = folderName + '/validateToken_error.json';
errorFilenamesByAPI['/refresh?showError=yes'] = folderName + '/refresh_error.json';
errorFilenamesByAPI['/userprofile?showError=yes'] = folderName + '/userprofile_error.json';
errorFilenamesByAPI['/logout?showError=yes'] = folderName + '/logout_error.json';
errorFilenamesByAPI['/API/UserGetDetail?showError=yes'] = folderName + '/UserGetDetail_Error.json';
errorFilenamesByAPI['/API/incidentGetList?showError=yes'] = folderName + '/incidentGetList_Error.json';
errorFilenamesByAPI['/API/incidentGetWorkInfo?showError=yes'] = folderName + '/incidentGetWorkInfo_Error.json';
errorFilenamesByAPI['/API/IncidentCreate?showError=yes'] = folderName + '/IncidentCreate_Error.json';

/// file reader
var fs = require('fs');

/// function to process the request
var processRequest = function (req, res, postParams) {
    var url_parts = url.parse(req.url, true);
    var query = url_parts.query;
    var json = JSON.parse('{}')
    var filename = '';
    // If need to return error, then use 'errorFilenamesByAPI'
    if (query.showError == "yes") {
        filename = errorFilenamesByAPI[url_parts.path];
    }
    else {
        filename = filenamesByAPI[url_parts.path];
    }
    // Read sample file
    if (filename) {
        console.log("reading file: " + filename)
        var text = fs.readFileSync(filename);
        json = JSON.parse(text.toString());
        
        // Replace access token with random
        if (url_parts.path == "/oauth2") {
            json.access_token = accessToken
        }
        else if (url_parts.path == "/refresh") {
            // skip checking token and return new access token
            json.access_token = accessToken
        }
        // Try check access token
        else if (query.showError != "yes") {
            if (req.headers.token == accessToken
                || req.headers.authorization == "Bearer " + accessToken
                || postParams.access_token == accessToken) {
                // access token is valid
                console.log("Access Token: VALID")
            }
            else {// Not valid access token. Read error sample respose and replace error message
           /* 
                console.log("Access Token: NOT VALID:")
                console.log("    Token: " + req.headers.token)
                console.log("    Authorization: " + req.headers.authorization)
                console.log("    access_token: " + postParams.access_token)
                filename = errorFilenamesByAPI[url_parts.path + "?showError=yes"];
                console.log(" reading error file: " + filename)
                var text = fs.readFileSync(filename);
                json = JSON.parse(text.toString());
                if (json.hasOwnProperty("soapenv:Fault")) {
                    json["soapenv:Fault"]["faultstring"] = "Access token is not valid" // for REST API
                }
                json["error_description"] = "Access token is not valid" // for OAuth server requests
            */
            }
        }
    }
    // Reply
    res.writeHead(200, {'Content-Type': 'application/json'});
    res.end(JSON.stringify(json));
}
// Start local HTTP server
console.log("Starting local HTTP server...")
http.createServer(function (req, res) {
    var url_parts = url.parse(req.url, true);
    var query = url_parts.query;

    console.log("REQUEST: " + url_parts.path)
    console.log(query);
    var postParams = {}
//    console.log("Headers: " + JSON.stringify(req.headers)); //  UNCOMMENT TO SEE ALL HEADERS IN THE LOG
                  
    // Read POST parameters
    if (req.method == 'POST') {
        var body = '';
        req.on('data', function (data) {
            body += data;
        });
        req.on('end', function () {
            console.log("BODY: " + body)
            if (req.headers["content-type"] == "application/json") {
               console.log("json post")
                postParams = JSON.parse(body)
            }
            else {
                postParams = url.parse(body, true).query;
            }
            console.log("POST parameters: " + JSON.stringify(postParams))
            processRequest(req, res, postParams)
        });
    }
    else {
        processRequest(req, res, postParams)
    }
}).listen(port);
console.log("DONE")
console.log("Access Token: " + accessToken)
