'use strict';

module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    mochacli: {
      options: {
        timeout: '60000',
        reporter: 'spec',
        grep: grunt.option('grep')
      },
      all: {
        src: ['test/build/*.js'] 
      }
    },
    fileConfig: {
      gruntfile: {
        src: 'Gruntfile.js'
      },
      lib: {
        src: ['lib/**/*.js']
      },
      test: {
        src: 'test/src/**/*.coffee'
      },
      source: {
        src: 'source/**/*.coffee'
      }
    },
    coffee: {
      sourceToLib: {
        expand: true,
        flatten: true,
        cwd: 'source',
        src: ['*.coffee'],
        dest: 'lib',
        ext: '.js'
      },
      testSourceToBuild: {
        expand: true,
        flatten: true,
        cwd: 'test/src',
        src: ['*.coffee'],
        dest: 'test/build',
        ext: '.js'
      }
    },
    watch: {
      test: {
        files: ['<%= fileConfig.test.src %>', '<%= fileConfig.source.src%>'],
        tasks: ['coffee', 'test']
      },
    },
    connect: {
      server: {
        options: {
          port: 9001,
          base: './test'
        }
      }
    }
  });

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-mocha-cli');
  grunt.loadNpmTasks('grunt-contrib-connect');

  // Default task.
  grunt.registerTask('test', ['coffee', 'connect', 'mochacli']);

};
