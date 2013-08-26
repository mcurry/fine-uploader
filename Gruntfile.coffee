# Gruntfile
#   for
# fineuploader

# the 'wrapper' function
module.exports = (grunt) ->

    require('time-grunt')(grunt)

    # Utilities
    # ==========
    path = require 'path'
    request = require 'request'

    # Package
    # ==========
    pkg = require './package.json'

    # Paths
    # ==========
    paths =
        'dist': './_dist'
        'build': './_build'
        'src': './client'
        'docs': './docs'
        'test': './test'

    # Browsers
    # ==========
    browsers = require "#{paths.test}/browsers.json"

    # Modules
    # ==========
    # Core modules
    core = [
        "#{paths.src}/js/util.js",
        "#{paths.src}/js/version.js",
        "#{paths.src}/js/features.js",
        "#{paths.src}/js/promise.js",
        "#{paths.src}/js/button.js",

        # TODO tied to the upload via paste feature and can be omitted or included in the combined file based on integrator prefs (#846)
        "#{paths.src}/js/paste.js",

        "#{paths.src}/js/upload-data.js",
        "#{paths.src}/js/uploader.basic.api.js",
        "#{paths.src}/js/uploader.basic.js",

        # TODO tied to the DnD feature and can be omitted or included in the combined file based on integrator prefs (#846)
        "#{paths.src}/js/dnd.js",

        "#{paths.src}/js/uploader.api.js",
        "#{paths.src}/js/uploader.js",
        "#{paths.src}/js/ajax.requester.js",

        # TODO tied to the delete file feature and can be omitted or included in the combined file based on integrator prefs (#846)
        "#{paths.src}/js/deletefile.ajax.requester.js",

        # TODO tied to the CORS feature and can be omitted or included in the combined file based on integrator prefs (#846)
        "#{paths.src}/js/window.receive.message.js",

        "#{paths.src}/js/handler.base.js",
        "#{paths.src}/js/handler.xhr.api.js",
        "#{paths.src}/js/handler.form.api.js",

        # TODO tied to the edit filename feature and can be omitted or included in the combined file based on integrator prefs (#846)
        "#{paths.src}/js/ui.handler.events.js",
        "#{paths.src}/js/ui.handler.click.drc.js",
        "#{paths.src}/js/ui.handler.edit.filename.js",
        "#{paths.src}/js/ui.handler.click.filename.js",
        "#{paths.src}/js/ui.handler.focusin.filenameinput.js",
        "#{paths.src}/js/ui.handler.focus.filenameinput.js"
    ]

    traditional = [
        "#{paths.src}/js/traditional/handler.form.js",
        "#{paths.src}/js/traditional/handler.xhr.js"
    ]

    s3 = [
        "#{paths.src}/js/s3/util.js",
        "#{paths.src}/js/s3/uploader.basic.js",
        "#{paths.src}/js/s3/uploader.js",
        "#{paths.src}/js/s3/signature.ajax.requester.js",
        "#{paths.src}/js/s3/uploadsuccess.ajax.requester.js",
        "#{paths.src}/js/s3/multipart.initiate.ajax.requester.js",
        "#{paths.src}/js/s3/multipart.complete.ajax.requester.js",
        "#{paths.src}/js/s3/multipart.abort.ajax.requester.js",
        "#{paths.src}/js/s3/handler.xhr.js",
        "#{paths.src}/js/s3/handler.form.js",
        "#{paths.src}/js/s3/jquery-plugin.js"
    ]

    # jQuery plugin modules
    jquery = core.concat "#{paths.src}/js/jquery-plugin.js",

                         # TODO tied to the DnD feature and can be omitted or included in the combined file based on integrator prefs (#846)
                         "#{paths.src}/js/jquery-dnd.js"

    all = jquery.concat (traditional.concat s3)

    extra = [
        "#{paths.src}/js/iframe.xss.response.js"
        "#{paths.src}/loading.gif",
        "#{paths.src}/processing.gif",
        "#{paths.src}/edit.gif",
        "./README.md",
        "./LICENSE"
    ]

    versioned = [
        "package.json",
        "fineuploader.jquery.json",
        "#{paths.src}/js/version.js",
        "bower.json",
        "README.md"
    ]


    # Configuration
    # ==========
    grunt.initConfig

        pkg: pkg

        bower:
            install:
                options:
                    targetDir: "#{paths.test}/_vendor"
                    install: true
                    cleanTargetDir: true
                    cleanBowerDir: true
                    layout: 'byComponent'

        clean:
            build:
                files:
                    src: paths.build
            dist:
                files:
                    src: paths.dist
            test:
                files:
                    src: ["#{paths.test}/_temp*"]
            vendor:
                files:
                    src: "#{paths.test}/_vendor"

        coffeelint:
            options:
                indentation:
                    level: 'ignore'
                no_trailing_whitespace:
                    level: 'ignore'
                max_line_length:
                    level: 'ignore'
            grunt: './Gruntfile.coffee'

        compress:
            jquery:
                 options:
                     archive: "#{paths.dist}/jquery.<%= pkg.name %>-<%= pkg.version %>.zip"
                 files: [
                     {
                         expand: true
                         cwd: paths.dist
                         src: './jquery.<%= pkg.name %>-<%= pkg.version %>/*'
                     }
                 ]
             jqueryS3:
                  options:
                      archive: "#{paths.dist}/s3.jquery.<%= pkg.name %>-<%= pkg.version %>.zip"
                  files: [
                      {
                          expand: true
                          cwd: paths.dist
                          src: './s3.jquery.<%= pkg.name %>-<%= pkg.version %>/*'
                      }
                  ]
            core:
                options:
                    archive: "#{paths.dist}/<%= pkg.name %>-<%= pkg.version %>.zip"
                files: [
                    {
                        expand: true
                        cwd: paths.dist
                        src: './<%= pkg.name %>-<%= pkg.version %>/*'
                    }
                ]
            coreS3:
                options:
                    archive: "#{paths.dist}/s3.<%= pkg.name %>-<%= pkg.version %>.zip"
                files: [
                    {
                        expand: true
                        cwd: paths.dist
                        src: './s3.<%= pkg.name %>-<%= pkg.version %>/*'
                    }
                ]

        concat:
            core:
                src: core.concat traditional
                dest: "#{paths.build}/<%= pkg.name %>.js"
            coreS3:
                src: core.concat s3
                dest: "#{paths.build}/s3.<%= pkg.name %>.js"
            jquery:
                src: jquery.concat traditional
                dest: "#{paths.build}/jquery.<%= pkg.name %>.js"
            jqueryS3:
                src: jquery.concat s3
                dest: "#{paths.build}/s3.jquery.<%= pkg.name %>.js"
            all:
                src: all
                dest: paths.build + "/all.<%= pkg.name %>.js"
            css:
                src: ["#{paths.src}/*.css"]
                dest: "#{paths.build}/<%= pkg.name %>.css"

        concurrent:
            minify: ['cssmin', 'uglify']
            lint: ['jshint', 'coffeelint']

        connect:
            root_server:
                options:
                    base: "."
                    hostname: "0.0.0.0"
                    port: 9000
                    keepalive: true
            test_server:
                options:
                    base: "test"
                    hostname: "0.0.0.0"
                    port: 9000

        copy:
            dist:
                files: [
                    {
                        expand: true
                        cwd: paths.build
                        src: ['*.js', '!all.*', '!s3.*', '!*.min.js', '!jquery*', '!*iframe*']
                        dest: "#{paths.dist}/<%= pkg.name %>-<%= pkg.version %>/"
                        ext: '-<%= pkg.version %>.js'
                    }
                    {
                        expand: true
                        cwd: paths.build
                        src: [ '!all.*', 's3.*.js', '!*.min.js', '!s3.jquery*', '!*iframe*']
                        dest: "#{paths.dist}/s3.<%= pkg.name %>-<%= pkg.version %>/"
                        ext: '.<%= pkg.name %>-<%= pkg.version %>.js'
                    }
                    {
                        expand: true
                        cwd: paths.build
                        src: ['*.min.js',  '!all.*', '!s3.*', '!jquery*']
                        dest: "#{paths.dist}/<%= pkg.name %>-<%= pkg.version %>/"
                        ext: '-<%= pkg.version %>.min.js'
                    }
                    {
                        expand: true
                        cwd: paths.build
                        src: ['s3.*.min.js', '!s3.jquery*']
                        dest: "#{paths.dist}/s3.<%= pkg.name %>-<%= pkg.version %>/"
                        ext: '.<%= pkg.name %>-<%= pkg.version %>.min.js'
                    }
                    {
                        expand: true
                        cwd: paths.build
                        src: ['jquery*js', '!s3.*', '!*.min.js']
                        dest: "#{paths.dist}/jquery.<%= pkg.name %>-<%= pkg.version %>/"
                        ext: '.<%= pkg.name %>-<%= pkg.version %>.js'
                    },
                    {
                        expand: true
                        cwd: paths.build
                        src: ['s3.jquery*js', '!*.min.js']
                        dest: "#{paths.dist}/s3.jquery.<%= pkg.name %>-<%= pkg.version %>/"
                        ext: '.jquery.<%= pkg.name %>-<%= pkg.version %>.js'
                    },
                    {
                        expand: true
                        cwd: paths.build
                        src: ['jquery*min.js']
                        dest: "#{paths.dist}/jquery.<%= pkg.name %>-<%= pkg.version %>/"
                        ext: '.<%= pkg.name %>-<%= pkg.version %>.min.js'
                    }
                    {
                        expand: true
                        cwd: paths.build
                        src: ['s3.jquery*min.js']
                        dest: "#{paths.dist}/s3.jquery.<%= pkg.name %>-<%= pkg.version %>/"
                        ext: '.jquery.<%= pkg.name %>-<%= pkg.version %>.min.js'
                    }
                    {
                        expand: true
                        cwd: "./#{paths.src}/js/"
                        src: ['iframe.xss.response.js']
                        dest: "#{paths.dist}/<%= pkg.name %>-<%= pkg.version %>/"
                        ext: '.xss.response-<%= pkg.version %>.js'
                    }
                    {
                        expand: true
                        cwd: "./#{paths.src}/js/"
                        src: ['iframe.xss.response.js']
                        dest: "#{paths.dist}/s3.<%= pkg.name %>-<%= pkg.version %>/"
                        ext: '.xss.response-<%= pkg.version %>.js'
                    }
                    {
                        expand: true
                        cwd: "./#{paths.src}/js/"
                        src: ['iframe.xss.response.js']
                        dest: "#{paths.dist}/jquery.<%= pkg.name %>-<%= pkg.version %>/"
                        ext: '.xss.response-<%= pkg.version %>.js'
                    }
                    {
                        expand: true
                        cwd: "./#{paths.src}/js/"
                        src: ['iframe.xss.response.js']
                        dest: "#{paths.dist}/s3.jquery.<%= pkg.name %>-<%= pkg.version %>/"
                        ext: '.xss.response-<%= pkg.version %>.js'
                    }
                    {
                        expand: true
                        cwd: paths.src
                        src: ['*.gif']
                        dest: "#{paths.dist}/<%= pkg.name %>-<%= pkg.version %>/"
                    }
                    {
                        expand: true
                        cwd: paths.src
                        src: ['*.gif']
                        dest: "#{paths.dist}/s3.<%= pkg.name %>-<%= pkg.version %>/"
                    }
                    {
                        expand: true
                        cwd: paths.src
                        src: ['*.gif']
                        dest: "#{paths.dist}/jquery.<%= pkg.name %>-<%= pkg.version %>/"
                    }
                    {
                        expand: true
                        cwd: paths.src
                        src: ['*.gif']
                        dest: "#{paths.dist}/s3.jquery.<%= pkg.name %>-<%= pkg.version %>/"
                    }
                    {
                        expand: true
                        cwd: './'
                        src: ['LICENSE']
                        dest: "#{paths.dist}/<%= pkg.name %>-<%= pkg.version %>/"
                    }
                    {
                        expand: true
                        cwd: './'
                        src: ['LICENSE']
                        dest: "#{paths.dist}/s3.<%= pkg.name %>-<%= pkg.version %>/"
                    }
                    {
                        expand: true
                        cwd: './'
                        src: ['LICENSE']
                        dest: "#{paths.dist}/jquery.<%= pkg.name %>-<%= pkg.version %>/"
                    }
                    {
                        expand: true
                        cwd: './'
                        src: ['LICENSE']
                        dest: "#{paths.dist}/s3.jquery.<%= pkg.name %>-<%= pkg.version %>/"
                    }
                    {
                        expand: true
                        cwd: paths.build
                        src: ['*.min.css']
                        dest: "#{paths.dist}/<%= pkg.name %>-<%= pkg.version %>"
                        ext: '-<%= pkg.version %>.min.css'
                    }
                    {
                        expand: true
                        cwd: paths.build
                        src: ['*.min.css']
                        dest: "#{paths.dist}/s3.<%= pkg.name %>-<%= pkg.version %>"
                        ext: '-<%= pkg.version %>.min.css'
                    }
                    {
                        expand: true
                        cwd: paths.build
                        src: ['*.css', '!*.min.css']
                        dest: "#{paths.dist}/<%= pkg.name %>-<%= pkg.version %>"
                        ext: '-<%= pkg.version %>.css'
                    }
                    {
                        expand: true
                        cwd: paths.build
                        src: ['*.css', '!*.min.css']
                        dest: "#{paths.dist}/s3.<%= pkg.name %>-<%= pkg.version %>"
                        ext: '-<%= pkg.version %>.css'
                    }
                    {
                        expand: true
                        cwd: paths.build
                        src: ['*.min.css']
                        dest: "#{paths.dist}/jquery.<%= pkg.name %>-<%= pkg.version %>"
                        ext: '-<%= pkg.version %>.min.css'
                    }
                    {
                        expand: true
                        cwd: paths.build
                        src: ['*.min.css']
                        dest: "#{paths.dist}/s3.jquery.<%= pkg.name %>-<%= pkg.version %>"
                        ext: '-<%= pkg.version %>.min.css'
                    }
                    {
                        expand: true
                        cwd: paths.build
                        src: ['*.css', '!*.min.css']
                        dest: "#{paths.dist}/jquery.<%= pkg.name %>-<%= pkg.version %>"
                        ext: '-<%= pkg.version %>.css'
                    }
                    {
                        expand: true
                        cwd: paths.build
                        src: ['*.css', '!*.min.css']
                        dest: "#{paths.dist}/s3.jquery.<%= pkg.name %>-<%= pkg.version %>"
                        ext: '-<%= pkg.version %>.css'
                    }
                ]
            build:
                files: [
                    {
                        expand: true
                        cwd: "#{paths.src}/js/"
                        src: ['iframe.xss.response.js']
                        dest: paths.build
                    },
                    {
                        expand: true
                        cwd: paths.src
                        src: ['*.gif']
                        dest: paths.build
                    }
                ]
            test:
                expand: true
                flatten: true
                src: ["#{paths.build}/*"]
                dest: "#{paths.test}/_temp"
            images:
                files: [
                    expand: true
                    cwd: paths.src
                    src: ['*.gif']
                    dest: paths.build
                ]

        cssmin:
            options:
                banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
                report: 'min'
            files:
                src: '<%= concat.css.dest %>'
                dest: "#{paths.build}/<%= pkg.name %>.min.css"


        jshint:
            source: ["#{paths.src}/js/*.js"]
            tests: ["#{paths.test}unit/*.js"]
            options:
                validthis: true
                laxcomma: true
                laxbreak: true
                browser: true
                eqnull: true
                debug: true
                devel: true
                boss: true
                expr: true
                asi: true

        open:
            test:
                path: 'http://localhost:9000'
                app: 'Google Chrome'

        uglify:
            options:
                mangle: true
                compress: true
                report: 'min'
                preserveComments: 'some'
            core:
                src: ['<%= concat.core.dest %>']
                dest: "#{paths.build}/<%= pkg.name %>.min.js"
            jquery:
                src: ['<%= concat.jquery.dest %>']
                dest: "#{paths.build}/jquery.<%= pkg.name %>.min.js"
            coreS3:
                src: ['<%= concat.coreS3.dest %>']
                dest: "#{paths.build}/s3.<%= pkg.name %>.min.js"
            jqueryS3:
                src: ['<%= concat.jqueryS3.dest %>']
                dest: "#{paths.build}/s3.jquery.<%= pkg.name %>.min.js"
            all:
                src: ['<%= concat.all.dest %>']
                dest: "#{paths.build}/all.<%= pkg.name %>.min.js"

        usebanner:
            header:
                src: ["#{paths.build}/*.{js,css}"]
                options:
                    position: 'top'
                    banner: '''
                            /*!
                             * <%= pkg.title %>
                             *
                             * Copyright 2013, <%= pkg.author %> info@fineuploader.com
                             *
                             * Version: <%= pkg.version %>
                             *
                             * Homepage: http://fineuploader.com
                             *
                             * Repository: <%= pkg.repository.url %>
                             *
                             * Licensed under GNU GPL v3, see LICENSE
                             */ \n\n'''
            footer:
                src: ["#{paths.build}/*.{js,css}"]
                options:
                    position: 'bottom'
                    banner: '/*! <%= grunt.template.today("yyyy-mm-dd") %> */\n'

        version:
            options:
                pkg: pkg,
                prefix: '[^\\-][Vv]ersion[\'"]?\\s*[:=]\\s*[\'"]?'
            major:
                options:
                    release: 'major'
                src: versioned
            minor:
                options:
                    release: 'minor'
                src: versioned
            hotfix:
                options:
                    release: 'patch'
                src: versioned
            build:
                options:
                    release: 'build'
                src: versioned

        watch:
            options:
                interrupt: true
                debounceDelay: 250
            js:
                files: ["#{paths.src}/js/*.js", "#{paths.src}/js/s3/*.js"]
                tasks: [
                    'build'
                    'copy:test'
                    'test-unit'
                ]
            test:
                files: ["#{paths.test}/unit/*.js", "#{paths.test}/unit/s3/*.js"]
                tasks: [
                    'jshint:tests'
                    'test-unit'
                ]
            grunt:
                files: ['./Gruntfile.coffee']
                tasks: [
                    'coffeelint:grunt'
                    'build'
                ]
            images:
                files: ["#{paths.src}/*.gif"]
                tasks: [
                    'copy:images'
                ]

        # Tests
        # ----------
        mocha:
            unit:
                options:
                    urls: ['http://localhost:9000/index.html']
                    log: true
                    mocha:
                        ignoreLeaks: false
                    reporter: 'Spec'
                    run: true 

        'mocha-sauce':
            options:
                username: process.env.SAUCE_USERNAME || process.env.USER || ''
                accessKey: process.env.SAUCE_ACCESS_KEY || ''
                tunneled: true
                timeout: 3000
                concurrency: 3
                identifier: process.env.TRAVIS_JOB_ID || Math.floor((new Date).getTime() / 1000 - 1230768000).toString()
                tags: [ process.env.SAUCE_USERNAME+"@"+process.env.TRAVIS_BRANCH || process.env.SAUCE_USERNAME+"@local"]
                build: process.env.TRAVIS_BUILD_ID || Math.floor((new Date).getTime() / 1000 - 1230768000).toString()
            unit:
                options:
                    url: 'http://localhost:9000/index.html'
                    name: "UnitTests"
                    browsers: browsers.unit

    # Dependencies
    # ==========
    for name of pkg.devDependencies when name.substring(0, 6) is 'grunt-'
        grunt.loadNpmTasks name

    grunt.loadTasks './lib/tasks'

    # Tasks
    # ==========

    # General Tasks
    # ----------
    grunt.registerTask 'lint', 'Lint, in order, the Gruntfile, sources, and tests.', [
        'concurrent:lint'
    ]

    grunt.registerTask 'minify', 'Minify the source javascript and css', [
        'concurrent:minify'
    ]

    # Testing Tasks 
    # ----------
    grunt.registerTask 'check_for_pull_request_from_master', 'Fails if we are testing a pull request against master', ->
        if (process.env.TRAVIS_BRANCH == 'master' and process.env.TRAVIS_PULL_REQUEST != 'false')
            grunt.fail.fatal '''Woah there, buddy! Pull requests should be
            branched from develop!\n
            Details on contributing pull requests found here: \n
            https://github.com/Widen/fine-uploader/blob/master/CONTRIBUTING.md\n
            '''

    grunt.registerTask 'travis', [
        'check_for_pull_request_from_master'
        'travis-sauce'
    ]

    grunt.registerTask 'test-watch', 'Run headless unit-tests and re-run on file changes', [
        'prepare-test'
        'connect:test_server'
        'open:test'
        'watch'
    ]

    grunt.registerTask 'test-unit', 'Run headless unit tests', [
        'prepare-test'
        'connect:test_server'
        'mocha:unit'
    ]

    grunt.registerTask 'test-unit-sauce', 'Run tests on SauceLabs', [
        'prepare-test'
        'connect:test_server'
        'mocha-sauce:unit'
    ]

    grunt.registerTask 'test-unit-forever', 'Run a local server for indefinite unit testing', [
        'prepare-test'
        'connect:root_server'
        'open:test'
    ]

    grunt.registerTask 'test-functional', 'ITW: Run functional tests', [
        'prepare-test'
        'connect:test_server'
        'mocha:functional'
    ]

    grunt.registerTask 'test-functional-sauce', 'ITW: Run functional tests (SauceLabs)', [
        'prepare-test'
        'connect:test_server'
        'mocha-sauce:functional'
    ]

    # Building Tasks
    # ----------

    grunt.registerTask 'prepare-test', 'Prepare code for testing', [
        'rebuild'
        'copy:test'
    ]

    grunt.registerTask 'prepare', 'Prepare the environment for development', [
        'clean'
        'bower'
    ]

    grunt.registerTask 'rebuild', "Rebuild the environment and source", [
        'prepare',
        'build'
    ]

    grunt.registerTask 'build', 'Build from latest source', [
        'concat'
        'minify'
        'usebanner'
        'copy:images'
    ]

    grunt.registerTask 'release', 'Build a zipped distribution-worthy version', [
        'build'
        'copy:dist'
        'compress'
    ]

    grunt.registerTask 'default', 'Default task: clean, bower, lint, build, & test', [
        'release'
    ]
