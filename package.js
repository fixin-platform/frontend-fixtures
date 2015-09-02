var description = {
  summary: "Frontend Fixtures",
  version: "1.0.0",
  name: "fixtures"
};
Package.describe(description);

var path = Npm.require("path");
var fs = Npm.require("fs");
eval(fs.readFileSync("./packages/autopackage.js").toString());
Package.onUse(function(api) {
  addFiles(api, description.name, getDefaultProfiles());
  api.use(["foundation"]);
  api.use([
    "percolate:migrations@0.7.3"
  ]);
  api.export([
    "Migrations",
    "Fixtures"
  ], ["server"])
});
