# Require modules
cc = require 'cli-color'
swig = require 'swig'
del = require 'del'
fs = require 'node-fs-extra'

# Metalsmith modules
metalsmith = require 'metalsmith'
templates = require 'metalsmith-templates'
serve = require 'metalsmith-serve'
watch = require 'metalsmith-watch'
define = require 'metalsmith-define'
postcss = require 'metalsmith-postcss'
sass = require 'metalsmith-sass'

# Turn off swig cache
swig.setDefaults
  cache: false

# Welcome text
console.log cc.blue '------------- JoshConley.com -------------\n'

# Switch depending on task
switch process.argv[2]
  when 'build'
    console.log cc.blue 'Starting build...\n'

    # Remove build directory
    del.sync './build'

    # Start Metalsmith
    metalsmith __dirname
      .use sass
        outputStyle: 'compressed'
      .use postcss [
        require 'autoprefixer'
        require 'css-mqpacker'
      ]
      .use define
        config:
          environment: 'production'
          assetUrl: 'http://cdn.joshconley.com'
          now: new Date()
      .use templates
        engine: 'swig'
        inPlace: true
      .build (error) ->
        if error
          console.log cc.red '! ERROR !'
          console.log error
        else
          ###
          console.log cc.blue 'Copying fonts...'
          fs.copySync '../src/fonts', './build/assets/fonts'
          ###

          console.log cc.blue 'Copying images...'
          fs.copySync './images', './build/assets/images'

          console.log cc.green '\nDone build.  No errors.'

  when 'serve'
    console.log cc.blue 'Starting local server...\n'

    # Start Metalsmith
    metalsmith __dirname
      .use sass
        outputStyle: 'expanded'
      .use postcss [
        require 'autoprefixer'
        require 'css-mqpacker'
      ]
      .use define
        config:
          environment: 'testing'
          assetUrl: 'assets'
          now: new Date()
      .use templates
        engine: 'swig'
        inPlace: true
      .use serve
        port: 5010
      .use watch
        paths:
          'src/**/*': '**/*'
          'templates/**/*': '**/*'
          '../src/**/*': '**/*'
      .build (error) ->
        if error
          console.log cc.red '! ERROR !'
          console.log error
          throw error
        else
          ###
          console.log cc.blue 'Copying fonts...'
          fs.copySync '../src/fonts', './build/assets/fonts'
          ###

          console.log cc.blue 'Copying images...'
          fs.copySync './images', './build/assets/images'

          console.log cc.green '\nDone build.  No errors.\nCTRL + C to exit.'