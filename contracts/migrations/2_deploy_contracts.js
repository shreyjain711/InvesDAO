var RaiseDao = artifacts.require("RaiseDao");

module.exports = function(deployer) {
    deployer.deploy(RaiseDao, "Testing", "TestDAO", "TDAO", 10);
    deployer.deploy(RaiseDao, "Climate Change", "TestDAO", "TDAO", 10);
    deployer.deploy(RaiseDao, "PolygonLeap", "PolygonLeapDAO", "PLDAO", 100);
};