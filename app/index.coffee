path = require 'path'
yeoman = require 'yeoman-generator'
semver = require 'semver'
yosay = require 'yosay'
chalk = require 'chalk'

module.exports = class RevealGenerator extends yeoman.generators.Base

    constructor: (args, options) ->
        yeoman.generators.Base.apply @, arguments
        @pkg = JSON.parse @readFileAsString path.join __dirname, '../package.json'

        # Setup config defaults.
        @config.defaults
            presentationTitle: 'Reveal.js and Yeoman is Awesomeness'
            packageVersion: '0.0.0'
            useSass: false
            deployToGithubPages: false
            githubUsername: 'example_username'
            githubRepository: 'example_repository'

        # When we are done:
        @on 'end', ->
            # Install deps.
            @installDependencies skipInstall: options['skip-install']
    askFor: ->
        cb = @async()
        # Have Yeoman greet the user.
        @log yosay()
        @log chalk.magenta(
            'This includes the amazing Reveal.js Framework\n' +
            'and a Grunt file for your presentation pleasure.\n'
        )
        prompts = [
            {
                name: 'presentationTitle'
                message: 'What are you going to talk about?'
                default: @config.get 'presentationTitle'
            }
            {
                name: 'packageVersion'
                message: 'What version should we put in the package.json file?'
                default: @config.get 'packageVersion'
                validate: (input) ->
                    return 'Please enter a correct semver version, i.e. MAJOR.MINOR.PATCH.' unless semver.valid input
                    true
            }
            {
                name: 'useSass'
                message: 'Do you want to use SASS to create a custom theme? This requires you to have Ruby and Sass installed.'
                type: 'confirm'
                default: @config.get 'useSass'
            }
            {
                name: 'deployToGithubPages'
                message: 'Do you want to deploy your presentation to Github Pages? This requires an empty Github repository.'
                type: 'confirm'
                default: @config.get 'deployToGithubPages'
            }
            {
                name: 'githubUsername'
                message: 'What is your Github username?'
                default:  @config.get 'githubUsername'
                when: (props) ->
                    return props.deployToGithubPages
            }
            {
                name: 'githubRepository'
                message: 'What is the Github repository name?'
                default: @config.get 'githubRepository'
                when: (props) ->
                    return props.deployToGithubPages
            }
        ]
        @prompt prompts, (props) =>
            # Write answers to `config`.
            @config.set 'presentationTitle', props.presentationTitle
            @config.set 'packageVersion', props.packageVersion
            @config.set 'useSass', props.useSass
            @config.set 'deployToGithubPages', props.deployToGithubPages
            @config.set 'githubUsername', props.githubUsername
            @config.set 'githubRepository', props.githubRepository
            cb()

    app: ->
        @template '_index.md', 'slides/index.md'
        @template '_Gruntfile.coffee', 'Gruntfile.coffee'
        @template '__index.html', 'templates/_index.html'
        @template '__section.html', 'templates/_section.html'
        @template '_package.json', 'package.json'
        @template '_bower.json', 'bower.json'
        @copy 'loadhtmlslides.js', 'js/loadhtmlslides.js'
        @copy 'list.json', 'slides/list.json'

        @copy 'theme.scss', 'css/source/theme.scss' if @config.get 'useSass'


        @template '_about.md', 'slides/about.md'
        @copy 'images/questions-paper.jpg', 'images/questions-paper.jpg'
        @copy 'images/whatznear-1.png', 'images/whatznear-1.png'
        @copy 'images/yeoman.png', 'images/yeoman.png'
        @copy 'css/custom.css', 'css/custom.css'

    projectfiles: ->
        @copy 'editorconfig', '.editorconfig'
        @copy 'jshintrc', '.jshintrc'

    runtime: ->
        @copy 'bowerrc', '.bowerrc'
        @copy 'gitignore', '.gitignore'


