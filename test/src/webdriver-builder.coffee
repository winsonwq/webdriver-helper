webdriver = require 'selenium-webdriver'
builder = new webdriver.Builder().usingServer 'http://localhost:4444/wd/hub'
builder = builder.withCapabilities { browserName: 'firefox' }

module.exports = builder