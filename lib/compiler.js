var ccss = require('ccss-compiler');
var vfl = require('./vfl-compiler');

exports.parse = function (rules) {
  var results = {
    selectors: [],
    vars: [],
    constraints: []
  };
  var parsed = vfl.parse(rules);
  parsed.forEach(function (rule) {
    var ccssRule = ccss.parse(rule[1]); 
    results.selectors = results.selectors.concat(ccssRule.selectors);
    results.vars = results.vars.concat(ccssRule.vars);
    results.constraints = results.constraints.concat(ccssRule.constraints);
  });
  return results;
};
