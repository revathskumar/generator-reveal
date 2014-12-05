# Generated on <%= (new Date).toISOString().split('T')[0] %> using <%= pkg.name %> <%= pkg.version %>
module.exports = (grunt) ->

    grunt.initConfig

        watch:

            livereload:
                options:
                    livereload: true
                files: [
                    'index.html'
                    'slides/{,*/}*.{md,html}'
                    'js/*.js'<% if (config.get('useSass')) { %>
                    'css/*.css'<% } %>
                ]

            index:
                files: [
                    'templates/_index.html'
                    'templates/_section.html'
                    'slides/list.json'
                ]
                tasks: ['buildIndex']

            coffeelint:
                files: ['Gruntfile.coffee']
                tasks: ['coffeelint']

            jshint:
                files: ['js/*.js']
                tasks: ['jshint']
        <% if (config.get('useSass')) { %>
            sass:
                files: ['css/source/theme.scss']
                tasks: ['sass']

        sass:

            theme:
                files:
                    'css/theme.css': 'css/source/theme.scss'
        <% } %>
        connect:

            livereload:
                options:
                    port: 9000
                    # Change hostname to '0.0.0.0' to access
                    # the server from outside.
                    hostname: 'localhost'
                    base: '.'
                    open: true
                    livereload: true

        coffeelint:

            options:
                indentation:
                    value: 4
                max_line_length:
                    level: 'ignore'

            all: ['Gruntfile.coffee']

        jshint:

            options:
                jshintrc: '.jshintrc'

            all: ['js/*.js']

        copy:

            dist:
                files: [{
                    expand: true
                    src: [
                        'slides/**'
                        'bower_components/**'
                        'js/**'<% if (config.get('useSass')) { %>
                        'css/*.css'<% } %>
                    ]
                    dest: 'dist/'
                },{
                    expand: true
                    src: ['index.html']
                    dest: 'dist/'
                    filter: 'isFile'
                }]

        <% if (config.get('deployToGithubPages')) { %>
        buildcontrol:

            options:
                dir: 'dist'
                commit: true
                push: true
                message: 'Built from %sourceCommit% on branch %sourceBranch%'
            pages:
                options:
                    remote: 'git@github.com:<%= config.get('githubUsername') %>/<%= config.get('githubRepository')%>.git'
                    branch: 'gh-pages'
        <% } %>


    # Load all grunt tasks.
    require('load-grunt-tasks')(grunt)

    grunt.registerTask 'buildIndex',
        'Build index.html from templates/_index.html and slides/list.json.',
        ->
            indexTemplate = grunt.file.read 'templates/_index.html'
            sectionTemplate = grunt.file.read 'templates/_section.html'
            slides = grunt.file.readJSON 'slides/list.json'

            html = grunt.template.process indexTemplate, data:
                slides:
                    slides
                section: (slide) ->
                    grunt.template.process sectionTemplate, data:
                        slide:
                            slide
            grunt.file.write 'index.html', html

    grunt.registerTask 'test',
        '*Lint* javascript and coffee files.', [
            'coffeelint'
            'jshint'
        ]

    grunt.registerTask 'serve',
        'Run presentation locally and start watch process (living document).', [
            'buildIndex'<% if (config.get('useSass')) { %>
            'sass'<% } %>
            'connect:livereload'
            'watch'
        ]

    grunt.registerTask 'server', ->
        grunt.log.warn
        'The `server` task has been deprecated.
         Use `grunt serve` to start a server.'
        grunt.task.run ['serve']

    grunt.registerTask 'dist',
        'Save presentation files to *dist* directory.', [
            'test'<% if (config.get('useSass')) { %>
            'sass'<% } %>
            'buildIndex'
            'copy'
        ]

    grunt.registerTask 'build_pdf', ->

        childProcess  = require('child_process')
        phantomjs     = require('phantomjs')
        binPath       = phantomjs.path
        done          = grunt.task.current.async()

        childArgs = [
           'bower_components/reveal.js/plugin/print-pdf/print-pdf.js',
           'http://localhost:9000/index.html?print-pdf',
           '<%= _.slugify(config.get('presentationTitle')) %>.pdf'
        ];

        childProcess.execFile binPath, childArgs, (error, stdout, stderr) ->
           grunt.log.writeln(stdout);
           done(error);

    <% if (config.get('deployToGithubPages')) { %>
    grunt.registerTask 'deploy',
        'Deploy to Github Pages', [
            'dist'
            'buildcontrol'
        ]
    <% } %>

    # Define default task.
    grunt.registerTask 'default', [
        'test'
        'server'
    ]
