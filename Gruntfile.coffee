module.exports = (grunt) ->

  pkg = require('./package.json')

  # Project configuration.
  grunt.initConfig
    pkg: pkg

    # CoffeeLint
    coffeelint:
      options:
        no_empty_param_list:
          level: 'error'
        arrow_spacing:
          level: 'error'
        line_endings:
          level: 'error'
          value: 'unix'
        max_line_length:
          level: 'error'
          value: 150
        no_empty_functions:
          level: 'error'
        no_interpolation_in_single_quotes:
          level: 'error'
        no_unnecessary_double_quotes:
          level: 'error'
        no_unnecessary_fat_arrows:
          level: 'error'

      source: ['src/*.coffee']
      grunt: 'Gruntfile.coffee'

    # Clean
    clean:
      files:
        src: 'dist/'
        # filter: 'isFile'


    # Compile CoffeeScript to JavaScript
    coffee:
      compile:
        options:
          bare: true
          sourceMap: false # true
        files: [
          expand: true
          cwd: 'src/'
          src: ['**/*.coffee']
          dest: 'dist/'
          ext: '.js'
        ]

    # Release a new version and push upstream
    bump:
      options:
        commit: true
        push: true
        pushTo: ''
        commitFiles: ['package.json', 'bower.json', 'dist/exchange.js']
        # Files to bump the version number of
        files: ['package.json', 'bower.json']

    watch:
      files: 'src/**/*.coffee'
      tasks: ['dist']


  # Dependencies
  # ============
  for name of pkg.dependencies when name.substring(0, 6) is 'grunt-'
    grunt.loadNpmTasks(name)
  for name of pkg.devDependencies when name.substring(0, 6) is 'grunt-'
    if grunt.file.exists("./node_modules/#{name}")
      grunt.loadNpmTasks(name)

  # Tasks
  # =====

  # Dist
  # -----
  grunt.registerTask 'dist', [
    'clean'
    'coffeelint'
    'coffee'
  ]

  # Version Bumps
  # -----
  grunt.registerTask 'release', [
    'dist'
    'bump:minor'
  ]
  grunt.registerTask 'release-major', [
    'dist'
    'bump'
  ]

  # Travis-CI
  # -----
  grunt.registerTask 'test', [
    'dist'
  ]

  # Default
  # -----
  grunt.registerTask 'default', [
    'dist'
  ]
