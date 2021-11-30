var WolframAlpha = artifacts.require("./WolframAlpha.sol");

module.exports = function(deployer) {
  deployer.deploy(WolframAlpha);
};
