syncAppsAndBlueprintsWithFixtures = ->
  fixtureAppId2AppId = {}
  for fixtureappId, fixtureApp of Foreach.fixtureApps
    app = Apps.findOne({key: fixtureApp.key})
    if app
      l("Apps:sync", {operation: "update", key: fixtureApp.key})
      _id = app._id
      Apps.update(_id, $set: fixtureApp) # run through hooks
    else
      l("Apps:sync", {operation: "insert", key: fixtureApp.key})
      _id = Apps.insert(fixtureApp)
    fixtureAppId2AppId[fixtureappId] = _id
  position = 1
  for fixtureActionId, fixtureAction of Foreach.fixtureBlueprints
    fixtureAction.position = position++
  for fixtureappId, fixtureBlueprints of _.groupBy(_.values(Foreach.fixtureBlueprints), "appId")
    appId = fixtureAppId2AppId[fixtureappId]
    throw "Couldn't find appId by fixtureappId: \"#{fixtureappId}\"" unless appId
    for fixtureBlueprint in fixtureBlueprints
      fixtureBlueprint.appId = appId
      action = Blueprints.findOne({key: fixtureBlueprint.key, appId: appId})
      if action
        l("Blueprints:sync", {operation: "update", appId: fixtureappId, key: fixtureBlueprint.key})
        _id = action._id
        Blueprints.update(_id, $set: fixtureBlueprint)
      else
        l("Blueprints:sync", {operation: "insert", appId: fixtureappId, key: fixtureBlueprint.key})
        _id = Blueprints.insert(fixtureBlueprint)
