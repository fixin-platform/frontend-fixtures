var description = {
  summary: "Frontend Fixtures",
  version: "1.0.0",
  name: "frontend-fixtures"
};
Package.describe(description);

var path = Npm.require("path");
var fs = Npm.require("fs");
eval(fs.readFileSync("./packages/autopackage.js").toString());
Package.onUse(function(api) {

  addFiles(api, description.name, getDefaultProfiles());

  api.use(["frontend-core@1.0.0"]);
  api.imply(["frontend-core"]);
  api.use([
    "percolate:migrations@0.7.3"
  ]);
  api.export([
    "Migrations",
    "Fixtures"
  ], ["server"])
});
