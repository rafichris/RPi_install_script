/**
 * Copyright 2013 IBM Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

// The `https` setting requires the `fs` module. Uncomment the following
// to make it available:
//var fs = require("fs");

module.exports = {
    // the tcp port that the Node-RED web server is listening on
    uiPort: '%%port%%',
    uiHost: '%%bind%%',

    // By default, the Node-RED UI accepts connections on all IPv4 interfaces.
    // The following property can be used to listen on a specific interface. For
    // example, the following would only allow connections from the local machine.
    //uiHost: "127.0.0.1",
    iobrokerInstance: '%%instance%%',
    iobrokerConfig: '%%config%%',
    allowCreationOfForeignObjects: '%%allowCreationOfForeignObjects%%',

    // Retry time in milliseconds for MQTT connections
    mqttReconnectTime: 15000,

    // Retry time in milliseconds for Serial port connections
    serialReconnectTime: 15000,

    // Retry time in milliseconds for TCP socket connections
    //socketReconnectTime: 10000,

    // Timeout in milliseconds for TCP server socket connections
    //  defaults to no timeout
    //socketTimeout: 120000,

    // Maximum number of lines in debug window before pruning
    debugMaxLength: 1000,

    // The file containing the flows. If not set, it defaults to flows_<hostname>.json
    flowFile: 'flows.json',

    // To enabled pretty-printing of the flow within the flow file, set the following
    //  property to true:
    flowFilePretty: true,
    
    // By default, all user data is stored in the Node-RED install directory. To
    // use a different location, the following property can be used
    userDir: __dirname + '/',

    // Node-RED scans the `nodes` directory in the install directory to find nodes.
    // The following property can be used to specify an additional directory to scan.
    nodesDir: '%%nodesdir%%',

    // By default, the Node-RED UI is available at http://localhost:1880/
    // The following property can be used to specify a different root path.
    // If set to false, this is disabled.
    //httpAdminRoot: '/admin',

    // You can protect the user interface with a userid and password by using the following property.
    // The password must be an md5 hash  eg.. 5f4dcc3b5aa765d61d8327deb882cf99 ('password')
    httpAdminAuth: '%%auth%%',

    // Some nodes, such as HTTP In, can be used to listen for incoming http requests.
    // By default, these are served relative to '/'. The following property
    // can be used to specifiy a different root path. If set to false, this is
    // disabled.
    //httpNodeRoot: '/nodes',
    
    // To password protect the node-defined HTTP endpoints, the following property
    // can be used.
    // The password must be an md5 hash  eg.. 5f4dcc3b5aa765d61d8327deb882cf99 ('password')
    //httpNodeAuth: {user:"user",pass:"5f4dcc3b5aa765d61d8327deb882cf99"},
    
    // When httpAdminRoot is used to move the UI to a different root path, the
    // following property can be used to identify a directory of static content
    // that should be served at http://localhost:1880/.
    //httpStatic: '/home/nol/node-red-dashboard/',

    // To password protect the static content, the following property can be used.
    // The password must be an md5 hash  eg.. 5f4dcc3b5aa765d61d8327deb882cf99 ('password')
    //httpStaticAuth: {user:"user",pass:"5f4dcc3b5aa765d61d8327deb882cf99"},
    
    // The following property can be used in place of 'httpAdminRoot' and 'httpNodeRoot',
    // to apply the same root to both parts.
    httpRoot: "'%%httpRoot%%'",
    
    // The following property can be used in place of 'httpAdminAuth' and 'httpNodeAuth',
    // to apply the same authentication to both parts.
    //httpAuth: {user:"user",pass:"5f4dcc3b5aa765d61d8327deb882cf99"},
    
    // The following property can be used to disable the editor. The admin API
    // is not affected by this option. To disable both the editor and the admin
    // API, use either the httpRoot or httpAdminRoot properties
    //disableEditor: false,
    
    // The following property can be used to enable HTTPS
    // See http://nodejs.org/api/https.html#https_https_createserver_options_requestlistener
    // for details on its contents.
    // See the comment at the top of this file on how to load the `fs` module used by
    // this setting.
    // 
    //https: {
    //    key: fs.readFileSync('privatekey.pem'),
    //    cert: fs.readFileSync('certificate.pem')
    //},

    // The following property can be used to configure cross-origin resource sharing
    // in the HTTP nodes.
    // See https://github.com/troygoode/node-cors#configuration-options for
    // details on its contents. The following is a basic permissive set of options:
    //httpNodeCors: {
    //    origin: "*",
    //    methods: "GET,PUT,POST,DELETE"
    //},
    
    // Anything in this hash is globally available to all functions.
    // It is accessed as context.global.
    // eg:
    //    functionGlobalContext: { os:require('os') }
    // can be accessed in a function block as:
    //    context.global.os

    valueConvert: '%%valueConvert%%',

    credentialSecret: "'%%credentialSecret%%'",
	
    functionGlobalContext: {
        //'%%functionGlobalContext%%'
        // os:require('os'),
        // bonescript:require('bonescript'),
        // arduino:require('duino')
    },
    // Configure the logging output
    logging: {
        // Only console logging is currently supported
        console: {
            // Level of logging to be recorded. Options are:
            // fatal - only those errors which make the application unusable should be recorded
            // error - record errors which are deemed fatal for a particular request + fatal errors
            // warn - record problems which are non fatal + errors + fatal errors
            // info - record information about the general running of the application + warn + error + fatal errors
            // debug - record information which is more verbose than info + info + warn + error + fatal errors
            // trace - record very detailed logging + debug + info + warn + error + fatal errors
            // off - turn off all logging (doesn't affect metrics or audit)
            level: "info",
            // Whether or not to include metric events in the log output
            metrics: false,
            // Whether or not to include audit events in the log output
            audit: false
        }
    },
    editorTheme: {
        projects: {
            enabled: '%%projectsEnabled%%'
        }
    },
    ui: {
      middleware: function (req, res, next) {
        path = require('path')
        if (['/icon64x64.png', '/icon120x120.png', '/icon192x192.png'].includes(req.url)) {
        //  res.sendFile(path.resolve(path.join('/var/www/html/favicon', req.url)))
        // /opt/iobroker/node_modules/iobroker.node-red/settings.js
          res.sendFile(path.resolve(path.join('/var/www/html/favicon/node-red-favicon.ico')))
        } else {
          next()
        }
      }
    }
};
