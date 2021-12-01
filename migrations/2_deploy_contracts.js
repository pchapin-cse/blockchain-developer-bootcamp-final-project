var Book = artifacts.require("./Book.sol");
var SimpleStorage = artifacts.require("./SimpleStorage.sol");
var WolframAlpha = artifacts.require("./WolframAlpha.sol");

module.exports = function(deployer) {
  deployer.deploy(Book);
  deployer.deploy(SimpleStorage);
  deployer.deploy(WolframAlpha);
};
