###
    mocha-sauce grunt task

    @author: Mark Feltner

###

defaultsObj =
    username: process.env.SAUCE_USERNAME
    accessKey: process.env.SAUCE_ACCESS_KEY
    identifier: `Math.floor((new Date()).getTime() / 1000 - 1230768000).toString()`
    tunneled: true
    timeout: 3000
    name: 'derp'
    url: ''
    tags: []
    browsers: [{}]


module.exports = (grunt) ->

    eventLog = (emitter) ->
        methods = ['write', 'writeln', 'error', 'ok', 'debug']
        methods.forEach (method) ->
            emitter.on 'log:'+method, (text) ->
                grunt.log[method](text);
            emitter.on 'verbose:'+method, (text) ->
                grunt.verbose[method](text)

    _ = (grunt.util || grunt.utils)._
    async = require 'async'
    path = require 'path'
    SauceTunnel = require 'sauce-tunnel'
    MochaSauce = require 'mocha-sauce'

    grunt.registerMultiTask 'mocha-sauce', 'Run Mocha tests on SauceLabs', ->
        # yes, this is an async task
        done = @async()
        # set options
        opts = @options defaultsObj

        grunt.verbose.writeln "Username: %s; Identifier: %s; Name: %s; Tags: %s",
            opts.username, opts.identifier, opts.name, opts.tags

        # check if files have been provided for selenium tests rather than
        # just unit tests
        if @filesSrc.length > 0
            scripts = _.map @filesSrc, (f) ->
                return require(path.resolve(f))

        # Instantiate mocha sauce
        mochaSauce = new MochaSauce opts
        # let's not record videos or screenshots to speed up tests for now
        # this can be overrided in the options
        mochaSauce.record false, false

        # define our browsers
        browsers = _.map opts.browsers, (b) ->
            _.extend b,
                'name': opts.name
                'tags': opts.tags
                'build': opts.build
                'tunnel-identifier': if opts.tunneled then opts.identifier else ''

        _.each opts.browsers, (browser) ->
            mochaSauce.browser browser

        ### SauceTunnel ###
        # instantiate the Sauce Tunnel
        tunnel = new SauceTunnel opts.username, opts.accessKey, opts.identifier,
            opts.tunneled, opts.timeout
        eventLog tunnel

        grunt.verbose.writeln "Tunnel ready\n", tunnel

        ### MochaSauce events ###
        mochaSauce.on 'init', (browser) ->
            grunt.log.ok '\t init : %s %s @ %s', browser.browserName, browser.version,
                browser.platform

        mochaSauce.on 'start', (browser) ->
            grunt.log.ok '\t start : %s %s @ %s', browser.browserName, browser.version,
                browser.platform

        mochaSauce.on 'end', (browser, res) ->
            grunt.log.ok '\t end : %s %s @ %s', browser.browserName, browser.version,
                browser.platform
            if res.failures > 0
                grunt.log.error "Passed: X"
            else
                grunt.log.ok "Passed: √"

        mochaSauce.on 'error', (browser) ->
            grunt.log.error '\t error : %s %s @ %s', browser.browserName, browser.version,
                browser.platform


        mochaSauce.on 'quit', (browser) ->
            grunt.log.ok '\t quit: %s %s @ %s', browser.browserName, browser.version,
                browser.platform

        grunt.verbose.writeln "MochaSauce ready\n", mochaSauce

        # Tunnel starts here ...
        grunt.log.writeln "=> Connecting to SauceLabs ... "
        tunnel.start (created) ->
            if not created?
                grunt.log.error "Could not connect to SauceLabs!"
                done false
                return
            grunt.log.ok "Connected to SauceLabs."

            withoutErrors = true
            # Check for Selenium scripts or plain ol' URLs for unit tests
            if scripts
                grunt.verbose.writeln "Found scripts! Looks like selenium tests"

                async.eachSeries scripts, (script, cb) ->
                    _url = script.url
                    _test = script.test

                    mochaSauce.url(_url); # set the url to load
                    mochaSauce.start _test, (err, res) ->
                        grunt.verbose.writeln "Tests Ran!"
                        if err?
                            grunt.log.error err
                        cb err
                , (err) ->
                    tunnel.stop ->
                        grunt.verbose.writeln "=> Disconnected from SauceLabs"
                        if err?
                            grunt.log.error err
                            done err
                        done null
            else
                # running unit tests by loading a url
                mochaSauce.url opts.url
                console.log ">> MOCHA URL: #{opts.url}"
                grunt.verbose.writeln "Found urls! Looks like unit tests."
                mochaSauce.start null, (err) ->
                    tunnel.stop ->
                        grunt.verbose.writeln "=> Disconnected from SauceLabs"
                        if err?
                            grunt.log.debug err
                            done err
                        done null
