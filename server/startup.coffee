fs = Npm.require('fs')

Foreach.databaseReset = not Migrations._collection.findOne("control")

Meteor.startup ->
  if Foreach.databaseReset
    Fixtures.load([])
  Foreach.migrate()
  return unless Meteor.settings.public.isDebug
  return unless Meteor.settings.autorun?.isEnabled
  step = Steps.findOne(Meteor.settings.autorun.selectors.step)
  user = Meteor.users.findOne(Meteor.settings.autorun.selectors.user)
  Commands.insert(
    isDryRun: true
    stepId: step._id
    userId: user._id
  )

process.on "SIGUSR2", Meteor.bindEnvironment ->
  filename = "/tmp/meteorReloadedCollectionNames"
  try
    fs.statSync(filename)
  catch err
    return if err.code is "ENOENT"
  reloadedCollectionNames = _.compact(fs.readFileSync(filename).toString().split("\n"))
  console.info("Reloading fixtures for " + if reloadedCollectionNames.length then reloadedCollectionNames.join(", ") else "all collections")
  Fixtures.load(reloadedCollectionNames)
  Foreach.migrate()
