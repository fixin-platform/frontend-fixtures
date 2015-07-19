fs = Npm.require('fs')
cluster = Npm.require('cluster')

Meteor.startup ->
  return if not cluster.isMaster
  if Foreach.databaseReset
    Foreach.loadFixtures([])
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
  return if not cluster.isMaster
  filename = "/tmp/meteorReloadedCollectionNames"
  try
    fs.statSync(filename)
  catch err
    return if err.code is "ENOENT"
  reloadedCollectionNames = _.compact(fs.readFileSync(filename).toString().split("\n"))
  console.info("Reloading fixtures for " + if reloadedCollectionNames.length then reloadedCollectionNames.join(", ") else "all collections")
  Foreach.loadFixtures(reloadedCollectionNames)
  Foreach.migrate()
