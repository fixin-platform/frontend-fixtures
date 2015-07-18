fs = Npm.require('fs')
cluster = Npm.require('cluster')

try
  Meteor.settings.local = JSON.parse Assets.getText("settings/#{Meteor.settings.public.pack}-#{Meteor.settings.public.env}.json")
catch e
  if ~e.toString().indexOf("Unknown asset") # that's normal
    Meteor.settings.local = {}
  else
    throw e

Meteor.startup ->
  return if not cluster.isMaster
  if Foreach.databaseReset
    Foreach.loadFixtures([])
  Foreach.migrate()
  return unless Meteor.settings.public.isDebug
  return unless Meteor.settings.local?.autorun?.isEnabled
  step = Steps.findOne(Meteor.settings.local.autorun.selectors.step)
  user = Meteor.users.findOne(Meteor.settings.local.autorun.selectors.user)
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
