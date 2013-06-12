module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # Generate library from Peg grammar
    peg:
      fbp:
        grammar: 'grammar/vfl-compiler.peg'
        outputFile: 'lib/vfl-compiler.js'

    # Build the browser Component
    component:
      install:
        options:
          action: 'install'
    component_build:
      'vfl-compiler':
        output: './browser/'
        config: './component.json'
        scripts: true
        styles: false

    # JavaScript minification for the browser
    uglify:
      options:
        report: 'min'
      noflo:
        files:
          './browser/vfl-compiler.min.js': ['./browser/vfl-compiler.js']

    # Automated recompilation and testing when developing
    watch:
      files: ['spec/*.coffee', 'grammar/*.peg', 'lib/compiler.js']
      tasks: ['test']

    # BDD tests on Node.js
    cafemocha:
      nodejs:
        src: ['spec/*.coffee']

    # CoffeeScript compilation
    coffee:
      spec:
        options:
          bare: true
        expand: true
        cwd: 'spec'
        src: ['**.coffee']
        dest: 'spec'
        ext: '.js'

    # BDD tests on browser
    mocha_phantomjs:
      all: ['spec/runner.html']

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-component'
  @loadNpmTasks 'grunt-peg'
  @loadNpmTasks 'grunt-component-build'
  @loadNpmTasks 'grunt-contrib-uglify'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-cafe-mocha'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-mocha-phantomjs'
  @loadNpmTasks 'grunt-contrib-watch'

  @registerTask 'build', ['peg', 'component', 'component_build', 'uglify']
  @registerTask 'test', ['build', 'coffee', 'cafemocha', 'mocha_phantomjs']
  @registerTask 'default', ['build']
