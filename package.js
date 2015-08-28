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

  //var foreachPackages = [],
  //  excludedPackages = ["ssl"],
  //  root = path.join("./packages"),
  //  entries = fs.readdirSync(root);

  //for (var i = 0; i < entries.length; i++) {
  //  var entryName = entries[i];
  //  if (fs.lstatSync(root + "/" + entryName).isDirectory() && entryName !== description.name && !~entryName.indexOf("meteor-") && !~excludedPackages.indexOf(entryName)) {
  //    foreachPackages.push(entryName);
  //  }
  //}
  //api.use(foreachPackages);
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
