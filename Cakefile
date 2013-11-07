fs = require 'fs'
path = require 'path'
{spawn} = require 'child_process'

INPUT_PATH = path.join __dirname, 'source'
OUTPUT_PATH = path.join __dirname, 'lib'
CMD = (process.platform == 'win32') ? 'coffee.cmd' : 'coffee'


task 'build', 'Build lib/ form source/', ->
  coffee = spawn CMD, ['-c', '-o', OUTPUT_PATH, INPUT_PATH]
  coffee.stderr.pipe process.stderr
  coffee.stdout.pipe process.stdout
  coffee.on 'error', (err) ->
    console.error err