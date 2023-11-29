---
link: https://groups.google.com/forum/#!topic/cloud9-ide/uaKRtlIxi4U
date: 2012-02-10 06:49 UTC
published: true
title: 'Cloud9: Node.js Environment Variables - Google Groups'
tags:
- nodejs
---

Here's how I would do it... I'd have a config file that's always loaded in my app,

config = require('./config')(express)

Then I have my config file which has something like:

module.exports = function(express) {
    var host = 'yourhost.com'
    var port = '1234'
    if (process.env.C9_PORT) {
         this.db = createClient( host, port, '213j23jk4hhjlks99wi3');
    } else if (process.env.NODE_ENV == 'production') {
         this.db = createClient( host, port, process.env.DB_PASS);
    } else if (process.env.NODE_ENV == 'test') {
           // test db or mock db connection
    } else {
          // maybe local db settings?
    }
    
    return this;
};

oh and I just passed express because when I did something like this with a config file, I had some additional server configuration that needed it
